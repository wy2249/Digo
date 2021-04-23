#!/bin/bash

# Testing script for Digo

# Reference: the regression testing script in MicroC

# This script first generates all dependencies including the
# Digo Library, Digo Linker, and Digo Compiler
# then it goes through a list of test files, 
#    Compile, run, and check the output.
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

        ../executable --master 127.0.0.1:20001 > "$exec_output" 2>/dev/null

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

Clean() {
    #make -C $MAKE_DIR clean &>/dev/null
    rm -f *.build.output
    rm -f *.exec.output
    rm -f *.diff.output
    rm -f *.linker.output
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
    echo "----------------- !!! Compiler not found ----------------------"
    BuildCompiler
fi


if [ $# -ge 1 ]
then
    files=$@
else
    files="tests/*.digo"
fi

for filename in $files; do
    RunTest "$(pwd)/$filename"
done


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
