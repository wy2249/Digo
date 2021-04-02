//
// Created by VM on 2021/3/27.
//

#ifndef DIGO_LINKER_AUTO_GC_H
#define DIGO_LINKER_AUTO_GC_H

#include <string>
using std::string;

#include "metadata.h"

class dsu;

class EscapeAnalyzer {
public:
    EscapeAnalyzer();
    void AutoAddDecRef();

private:
    void GenerateDecRef(const string& function);
    void InferFunctionRetType(vector<string> && functions);

private:
    vector<FuncPrototype> functions_to_trace_;

    const string c_wrapper_funcs[4] = {"ExtractString", "ExtractSlice",
                                      "CreateString", "AddString"};

    std::shared_ptr<dsu> funcs_to_infer_; // disjoint_set_union
};


#endif //DIGO_LINKER_AUTO_GC_H
