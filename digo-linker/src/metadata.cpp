//
// Created by VM on 2021/3/21.
//

#include "metadata.h"
#include <regex>
#include <sstream>

using namespace std;

const string metadata_begin = "; DIGO Async Function Metadata BEGIN";
const string metadata_end = "; DIGO Async Function Metadata END";

const regex version_regex("; VERSION = (\\d+)");

const regex func_decl_regex("; FUNC DECLARE BEGIN\n; FUNC_NAME = '(.+)'\n"
                            "; PARAMETERS = '(.+)'\n; RETURN_TYPE = '(.+)'\n"
                            "; FUNC DECLARE END\n");

class WrongVersionException: public exception {
public:
    const char * what() const noexcept override {
        return "metadata version != 1";
    }
};

class IncorrectMetadataException: public exception {
public:
    const char * what() const noexcept override {
        return "incorrect metadata";
    }
};

vector<string> split(const string &s, char delim) {
    vector<string> result;
    stringstream ss (s);
    string item;

    while (getline (ss, item, delim)) {
        result.push_back (item);
    }

    return result;
}

void Metadata::ParseFuncMetadataFromLLIR(const string &ir) {
    vector<FuncPrototype> ret;

    auto pos_begin = ir.find(metadata_begin) + metadata_begin.size();
    if (pos_begin == string::npos) {
        throw IncorrectMetadataException();
    }
    auto pos_end = ir.find(metadata_end, pos_begin);
    if (pos_end == string::npos) {
        throw IncorrectMetadataException();
    }

    auto metadata_part = ir.substr(pos_begin, pos_end - pos_begin + 1);

    regex multiple_newline(R"((\n|\r\n|\r)+)");
    metadata_part = regex_replace(metadata_part, multiple_newline, "\n");

    auto iter = sregex_iterator(metadata_part.begin(),
                                      metadata_part.end(), version_regex);

    for (; iter != sregex_iterator() ; iter++) {
        string ver = iter->str(1);
        if (stoi(ver) != 1) {
            throw WrongVersionException();
        }
    }

    iter = sregex_iterator(metadata_part.begin(), metadata_part.end(),
                           func_decl_regex);

    for (; iter != sregex_iterator() ; iter++) {
        string func_name = iter->str(1);
        string parameters = iter->str(2);
        string return_type = iter->str(3);
        if (func_name.empty()) {
            throw IncorrectMetadataException();
        }
        regex multiple_space("\\s+");
        parameters = regex_replace(parameters, multiple_space, "");
        return_type = regex_replace(return_type, multiple_space, "");

        FuncPrototype prototype;
        prototype.func_name = func_name;
        vector<string> p = split(parameters, ',');
        for(const string& str : p) {
            if (str == "int") {
                prototype.parameters.push_back(TYPE_INT64);
            } else if (str == "string") {
                prototype.parameters.push_back(TYPE_STR);
            }
        }

        p = split(return_type, ',');

        for(const string& str : p) {
            if (str == "int") {
                prototype.return_type.push_back(TYPE_INT64);
            } else if (str == "string") {
                prototype.return_type.push_back(TYPE_STR);
            } else {
                throw IncorrectMetadataException();
            }
        }
        ret.push_back(prototype);

    }

    functions_prototype_ = ret;
}

string Metadata::GenerateJumpTable() {
    string templ = R"(declare dso_local void async_call_provided_by_linker(i8* %func_name, ...))";
    return templ;
}

string Metadata::GenerateSerializerAsLLIR(const FuncPrototype &proto) {
    return std::string();
}

string Metadata::GenerateDeserializerAsLLIR(const FuncPrototype &proto) {
    return std::string();
}
