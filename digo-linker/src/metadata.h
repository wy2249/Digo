//
// Created by VM on 2021/3/21.
//

#ifndef DIGO_LINKER_METADATA_H
#define DIGO_LINKER_METADATA_H

#include "common.h"

#include <vector>

using std::vector;

class FuncPrototype {
public:
    string              func_name;
    int                 is_remote;
    vector<digo_type>   parameters;
    vector<digo_type>   return_type;
};

class FuncClosure {
public:
    string              func_name;
    vector<TypeCell>    parameters;
};

class Metadata: public noncopyable {
public:
    void    ParseFuncMetadataFromLLIR(const string & ir);

    string  GenerateJumpTable();
    string  GenerateAsyncCalls();

    string  GenerateDeclare();
    string  GenerateEntry();

private:

    string  GenerateAsyncAsLLVMIR(int id, const FuncPrototype & proto);

    string GenerateSerializer(const vector<digo_type> & types, const string & prefix);
    string GenerateExtractor(const vector<digo_type> & types, const string& padding);
    string GenerateArgumentsDef(const vector<digo_type> & types);

    string GenerateJumpLabel(int id, const FuncPrototype & proto);
    vector<FuncPrototype> functions_prototype_;

    std::tuple<string, string> GenerateFuncNameIdMap(int id, const FuncPrototype & proto);
};

#endif //DIGO_LINKER_METADATA_H
