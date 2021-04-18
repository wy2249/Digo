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
    echo "Usage: run_tests.sh [options] [.mc files]"
    echo "-k    Keep intermediate files"
    echo "-h    Print this help"
    exit 1
}

MAKE_DIR='../'
# Generate depenencies and Digo Compiler
BuildCompiler() {
    echo "------------------ Generating Compiler ------------------------"
    echo "Please wait......."
    make -C $MAKE_DIR clean &>nul
    make -C $MAKE_DIR generate-dependency &>nul
    make -C $MAKE_DIR generate-digo-compiler &>nul
    echo "------------------ Compiler Generated ------------------------"
}

global_test_error=0
global_test_error_any=0

# Compare <outfile> <reffile> <difffile>
# Compares the outfile with reffile. Differences, if any, written to difffile
Compare() {
    generatedfiles="$generatedfiles $3"
    echo diff -b $1 $2 ">" $3 1>&2
    diff -b "$1" "$2" > "$3" 2>&1 || {
        global_test_error=1
        echo "FAILED $1 differs from $2" 1>&2
    }
}

# RunTest <digofile>
#    Compile, run, and check the output.
#    If the compilation fails, it will diff
#       the error reported by the compiler and the $source_code.fail.expected
#    If the compilation succeeds, it will diff
#       the result produced by the executable and the $source_code.pass.expected
RunTest() {
    test_name="$1"
    test_src="$1"

    echo "---------- Running test: $test_name"

    make -C $MAKE_DIR build digo="$test_src" out=executable &>"$test_name.build.output"

    errorlevel=$?

    diff_output_file="$test_name.diff.output"

    if [ $errorlevel -eq 0 ] ; then
        # success expected, so try to run the executable
        echo "------------- Build success, trying to run the executable"
        echo "$test_name.output"
        ./executable --master 127.0.0.1:20001 > "$test_name.exec.output"
        expected_file="$test_name.pass.expected"
        exec_output="$test_name.exec.output"
        echo "--- Execution finished, trying to find the $expected_file"
        if [ ! -f $expected_file ]; then
            echo "$expected_file not found! The build should fail!"
            global_test_error=1
        else
            Compare "$build_output" "$expected_file" "$diff_output_file"
        fi
    else
        # fail expected, so try to diff the fail file
        expected_file="$test_name.fail.expected"
        build_output="$test_name.build.output"
        echo "------------- Build failed, trying to find the $expected_file"
        if [ ! -f $expected_file ]; then
            echo "$expected_file not found! The build should pass!"
            global_test_error=1
        else
            Compare "$build_output" "$expected_file" "$diff_output_file"
        fi
    fi

    if [ $global_test_error -eq 1 ] ; then
        global_test_error_any=1
    fi

    if [ $global_test_error -eq 1 ] ; then
        echo "! Test $1 Failed"
    else
        echo "Test $1 Passed"
    fi
}

Clean() {
    make -C $MAKE_DIR clean >nul 2>nul
    rm -f "*.build.output"
    rm -f "*.exec.output"
    rm -f "*.diff.output"
}

# Set time limit for all operations
ulimit -t 30
keep=0

while getopts kh c; do
    case $c in
	k) # Keep intermediate files
	    keep=1
	    ;;
	h) # Help
	    Usage
	    ;;
    esac
done

BuildCompiler

for filename in ./tests/*.digo; do
    RunTest "$(pwd)/$filename"
done


if [ $keep -eq 0 ] ; then
    Clean
fi

