#!/bin/bash

# Testing script for Digo

# Reference: the regression testing script in MicroC

# This script first generates the Digo Library, Digo Linker, and Digo Compiler,
#    if the Digo Compiler does not exist.

# then it goes through a list of test groups, 
# for each test group, we have a config.txt file which tells the script that 
#     how many workers the tests in this group need;
#     also, some options like GC_DEBUG can be enabled in this config.txt.
#    all tests in the same test group will use the same config.
# for each test, 
#    compile, run, and check the output.
#    If the compilation fails, it will diff
#       the error reported by the compiler and the $source_code.fail.expected
#    If the compilation succeeds, it will diff
#       the result produced by the executable and the $source_code.pass.expected

Usage() {
    echo "Usage: testall.sh [options] [.digo files]"
    echo "-k    Keep intermediate files"
    echo "-h    Print this help"
    exit 1
}

MAKE_DIR='../'
# Generate depenencies and Digo Compiler
BuildCompiler() {
    echo "------------------ Compiler not found -------------------------"
    echo "------------------ Generating Compiler ------------------------"
    echo "Please wait....... It may take 1-5 minutes to generate compiler"

    if ! make -C $MAKE_DIR clean &>/dev/null; then
      echo "clean failed "
      exit 1
    fi

    if ! make -C $MAKE_DIR generate-dependency &>/dev/null;
    then
      echo "build dependency failed"
      exit 1
    fi

    echo "Library compilation succeeds, now generating OCaml compiler..."
    if ! make -C $MAKE_DIR generate-digo-compiler &>/dev/null; then
      echo "build compiler failed"
      exit 1
    fi

    echo "------------------ Compiler Generated ------------------------"
}

global_test_error=0
global_test_error_any=0

global_log="testall.log"
global_llvm_ir_output_log="testall_ir.log"
rm -f $global_log
rm -f $global_llvm_ir_output_log

# Compare <outfile> <reffile> <difffile>
# Compares the outfile with reffile. Differences, if any, written to difffile
Compare() {
    generatedfiles="$generatedfiles $3"
    echo diff -b $1 $2 ">" $3 &>>"$global_log"
    diff -b "$1" "$2" > "$3" 2>&1 || {
        global_test_error=1
        echo "FAILED $1 differs from $2" >> "$global_log"
    }
}

WORKER_COUNT=0
GC_DEBUG=0
ENABLE_MASTER=0

LoadDefaultConfig() {
    WORKER_COUNT=0
    GC_DEBUG=0
    ENABLE_MASTER=0
}

# RunTest <digofile>
#    Compile, run, and check the output.
#    If the compilation fails, it will diff
#       the error reported by the compiler and the $source_code.fail.expected
#    If the compilation succeeds, it will diff
#       the result produced by the executable and the $source_code.pass.expected
RunTest() {
    global_test_error=0
    test_name=`echo $1 | sed 's/.*\\///
                             s/.digo//'`
    test_src="$1"

    echo -n "$test_name..."

    ../digo-compiler/digo.native "$test_src" > ../tmp.compiled.nometadata.ll 2>"$test_name.build.output"

    echo "" >> "$global_llvm_ir_output_log"
    echo "##### Testing $test_name" >> "$global_llvm_ir_output_log"
    cat ../tmp.compiled.nometadata.ll >> $global_llvm_ir_output_log

    errorlevel=$?

    if [ $errorlevel -eq 0 ] ; then
        make -C $MAKE_DIR build-link-pass digo="$test_src" out=executable &>"$test_name.linker.output"
        errorlevel=$?
    fi

    echo "" >> "$global_log"
    echo "##### Testing $test_name" >> "$global_log"

    diff_output_file="$test_name.diff.output"

    if [ $errorlevel -eq 0 ] ; then
        # success expected, so try to run the executable
        exec_output="$test_name.exec.output"
        expected_file="$test_src.pass.expected"

        if [ $ENABLE_MASTER -eq 0 ] ; then
            ../executable --no-master > "$exec_output" 2>/dev/null &
            master_pid=$!
        else
            # echo ../executable --master $MASTER_ADDR
            ../executable --master $MASTER_ADDR > "$exec_output" 2>/dev/null &
            master_pid=$!
        fi

        worker_pid=()
        if [ $WORKER_COUNT -gt 0 ] ; then
            for (( i = 0 ; i < $WORKER_COUNT ; i++ ))
            do
                # echo "Running worker $i"
                # echo ../executable --worker $MASTER_ADDR ${WORKER_ADDR[$i]}
                ../executable --worker $MASTER_ADDR ${WORKER_ADDR[$i]} > "$test_name.worker$i.output" 2>/dev/null &
                worker_pid[$i]=$!
            done
        fi

        wait $master_pid

        for pid in ${worker_pid[*]}; do
            kill -9 $pid
        done

        echo " ## Executable output: " >> "$global_log"
        cat "$exec_output" >> "$global_log"

        if [ ! -f $expected_file ]; then
            echo " ## Compilation passed, but we cannot find $expected_file" >> "$global_log"
            global_test_error=1
        else
            Compare "$exec_output" "$expected_file" "$diff_output_file"

            echo " ## Diff output: " >> "$global_log"
            cat "$diff_output_file" >> "$global_log"
        fi
    else
        # fail expected, so try to diff the fail file
        expected_file="$test_src.fail.expected"
        build_output="$test_name.build.output"
        
        echo " ## Build output: " >> "$global_log"
        cat "$build_output" >> "$global_log"

        if [ ! -f $expected_file ]; then
            echo " ## Compilation failed, but we cannot find $expected_file" >> "$global_log"
            global_test_error=1
        else
            Compare "$build_output" "$expected_file" "$diff_output_file"
            
            echo " ## Diff output: " >> "$global_log"
            cat "$diff_output_file" >> "$global_log"
        fi
    fi

    if [ $global_test_error -eq 1 ] ; then
        global_test_error_any=1
    fi

    if [ $global_test_error -eq 1 ] ; then
        echo "##### Test $test_name: Failed" >> "$global_log"
        echo "FAIL"
    else
        echo "##### Test $test_name: Passed" >> "$global_log"
        echo "OK"
    fi
}

RunTestFiles() {
    test_files=$@
    for filename in $test_files; do
        RunTest "$(pwd)/$filename"
    done
}

# RunTestGroup <test_group_dir>
RunTestGroup() {
    echo "--- Test Group: $1"
    group_dir=$1
    LoadDefaultConfig
    # load config

    . "$group_dir/config.txt"

    RunTestFiles "$group_dir/*.digo"
}

Clean() {
    # make -C $MAKE_DIR clean &>/dev/null
    rm -f *.build.output
    rm -f *.exec.output
    rm -f *.diff.output
    rm -f *.linker.output
    rm -f *.worker*.output
}

# Set time limit for all operations
ulimit -t 30
keep=0

while getopts kdpsh c; do
    case $c in
	k) # Keep intermediate files
	    keep=1
	    ;;
	h) # Help
	    Usage
	    ;;
    esac
done

shift `expr $OPTIND - 1`


if [ ! -f ../digo-compiler/digo.native ]; then
    BuildCompiler
fi


if [ $# -ge 1 ]
then
    RunTestFiles $@
else
    RunTestGroup "Basic"
    RunTestGroup "Async"
    RunTestGroup "Syntax"
    RunTestGroup "Semantic"
    RunTestGroup "ControlFlow"
    RunTestGroup "GC"
    RunTestGroup "Remote"
    RunTestGroup "Utils"
fi


if [ $keep -eq 0 ] ; then
    echo "Cleaning..."
    Clean
fi

echo "---------"

if [ $global_test_error_any -eq 1 ] ; then
    echo "Some tests failed, see $global_log for details"
else
    echo "All tests passed"
fi

exit $global_test_error_any
