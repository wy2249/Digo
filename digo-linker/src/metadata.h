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
    string  GenerateSerializerAsLLIR(const FuncPrototype & proto);
    string  GenerateDeserializerAsLLIR(const FuncPrototype & proto);

    string  ReplaceDigoLinkerCall(const string & ir);
private:
    vector<FuncPrototype> functions_prototype_;
};

#endif //DIGO_LINKER_METADATA_H
