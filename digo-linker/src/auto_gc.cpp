//
// Created by VM on 2021/3/27.
//

#include "auto_gc.h"

/* This function infers the return type of a LLVM IR function
 * generated by Digo Compiler.
 * The return types include Future Object, String, Slice
 * in the form of i8*.
 * We do not care about other types because they are
 * not allocated in heap.
 */
void EscapeAnalyzer::InferFunctionRetType(const string &function) {
    string regular_expr_of_c_wrapper_funcs;
    for (const string & func : c_wrapper_funcs) {
        regular_expr_of_c_wrapper_funcs += func + "|";
    }
    regular_expr_of_c_wrapper_funcs.pop_back();
    /* TODO: aggregated return unknown */
    if (1) {
        //this->functions_to_trace_.push_back("???");
    }

}

void EscapeAnalyzer::GenerateDecRef(const string &function) {
    /* object returned from c_wrapper_funcs & functions_to_trace_
     * are the targets of DecRef */

    /* when an object reaches the end of the function scope: */
    // TODO:
}

void EscapeAnalyzer::AutoAddDecRef() {

}

EscapeAnalyzer::EscapeAnalyzer() {

}
