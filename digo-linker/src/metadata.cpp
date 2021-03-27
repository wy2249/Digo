//
// Created by VM on 2021/3/21.
//

#include "metadata.h"
#include <regex>

#define FMT_HEADER_ONLY
#include "../third-party/fmt/format.h"

using namespace std;

const string metadata_begin = "; DIGO Async Function Metadata BEGIN";
const string metadata_end = "; DIGO Async Function Metadata END";

const regex version_regex("; VERSION = (\\d+)");

const regex func_decl_regex("; FUNC DECLARE BEGIN\n; FUNC_NAME = '(.+)'\n"
                            "; FUNC_ANNOT = '(.+)'\n"
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

class IncorrectIRException: public exception {
public:
    const char * what() const noexcept override {
        return "incorrect ir";
    }
};

vector<string> split(const string &s, char delim) {
    vector<string> result;
    stringstream ss (s);
    string item;

    while (getline (ss, item, delim)) {
        result.push_back(item);
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
        string func_annotation = iter->str(2);
        string parameters = iter->str(3);
        string return_type = iter->str(4);
        if (func_name.empty()) {
            throw IncorrectMetadataException();
        }
        regex multiple_space("\\s+");
        parameters = regex_replace(parameters, multiple_space, "");
        return_type = regex_replace(return_type, multiple_space, "");

        FuncPrototype prototype;
        if (func_annotation == "async") {
            prototype.is_remote = 0;
        } else if (func_annotation == "async remote") {
            prototype.is_remote = 1;
        } else {
            throw IncorrectMetadataException();
        }

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
    string jump_template = R"XXXXX(

define i32 @linker_call_function(i32 %func_id, i8* %arg, i32 %arg_len, i8** %result, i32* %result_len) {
  call void @Debug_Real_LinkerCallFunction(i32 %func_id, i32 %arg_len)

  %wrapper = call i8* @SW_CreateWrapper()
  %extractor = call i8* @SW_CreateExtractor(i8* %arg, i32 %arg_len)

  switch i32 %func_id, label %if.nomatch [

)XXXXX";

    for (int i = 0 ; i < functions_prototype_.size(); i++) {
        jump_template += "    i32 " + to_string(i) + ", label %if.func" + to_string(i);
    }

    jump_template += R"XXXXX(

  ]

#<labels>#

if.nomatch:
  call void @NoMatchExceptionHandler(i32 %func_id)
  ret i32 0

if.end:

  call void @SW_DestroyExtractor(i8* %extractor)

  ret i32 0
}

)XXXXX";

    jump_template = regex_replace(jump_template, regex("\\{"), "{{");
    jump_template = regex_replace(jump_template, regex("\\}"), "}}");
    jump_template = regex_replace(jump_template, regex("#<([a-z_]+)>#"), "{$1}");

    string labels;

    for (int i = 0; i < functions_prototype_.size(); i++) {
        labels += GenerateJumpLabel(i, functions_prototype_.at(i));
    }

    auto result = fmt::format(jump_template, fmt::arg("labels", labels));

    return result;
}

string Metadata::GenerateJumpLabel(int id, const FuncPrototype &proto) {
    // TODO: %arg0 should be %arg0, arg1, ...
    string label_template = R"XXXXX(
if.func#<id>#:
  #<arg_extractor>#

  %arg0 = call i32 @#<func_name>#(#<arguments>#)

  #<ret_serializer>#

  call void @SW_GetAndDestroy(i8* %wrapper, i8** %result, i32* %result_len)

  br label %if.end
)XXXXX";

    label_template = regex_replace(label_template, regex("\\{"), "{{");
    label_template = regex_replace(label_template, regex("\\}"), "}}");
    label_template = regex_replace(label_template, regex("#<([a-z_]+)>#"), "{$1}");

    auto result = fmt::format(label_template, fmt::arg("id", id),
                              fmt::arg("func_name", proto.func_name),
                              fmt::arg("arguments", GenerateArgumentsDef(proto.parameters)),
                              fmt::arg("arg_extractor", GenerateExtractor(proto.parameters, "arg")),
                              fmt::arg("ret_serializer", GenerateSerializer(proto.return_type)));
    return result;
}

string Metadata::GenerateSerializer(const vector<digo_type> & types) {
    string result;
    for (int i = 0; i < types.size(); i++) {
        auto type = types[i];
        if (type == TYPE_INT32) {
            result += R"(
  call void @SW_AddInt32(i8* %wrapper, i32 %arg)" + to_string(i) + ")";
        } else if (type == TYPE_INT64) {
            result += R"(
  call void @SW_AddInt64(i8* %wrapper, i64 %arg)" + to_string(i) + ")";
        } else if (type == TYPE_STR) {
            result += R"(
  call void @SW_AddString(i8* %wrapper, i8* %arg)" + to_string(i) + ")";
        }
    }
    return result;
}

// each item extracted is stored in %<padding>ID
string Metadata::GenerateExtractor(const vector<digo_type> & types, const string& padding) {
    // TODO: waiting for aggregated return type!
    string result;
    for (int i = 0; i < types.size(); i++) {
        auto type = types[i];
        if (type == TYPE_INT32) {
            result += R"(
  %)" + padding + to_string(i) +  R"( = call i32 @SW_ExtractInt32(i8* %extractor)
)";
        } else if (type == TYPE_INT64) {
            result += R"(
  %)" + padding + to_string(i) +  R"( = call i64 @SW_ExtractInt64(i8* %extractor)
)";
        } else if (type == TYPE_STR) {
            result += R"(
  %)" + padding + to_string(i) +  R"( = call i8* @SW_ExtractString(i8* %extractor)
)";
        }
    }
    return result;
}

string Metadata::GenerateArgumentsDef(const vector<digo_type> &types) {
    string result;
    if (types.empty()) return result;
    for (int i = 0; i < types.size(); i++) {
        auto type = types[i];
        if (type == TYPE_INT32) {
            result += R"(i32 %arg)" + to_string(i) + ", ";
        } else if (type == TYPE_INT64) {
            result += R"(i64 %arg)" + to_string(i) + ", ";
        } else if (type == TYPE_STR) {
            result += R"(i8* %arg)" + to_string(i) + ", ";
        }
    }
    result = result.substr(0, result.length() - 2);
    return result;
}

string Metadata::GenerateAsyncAsLLVMIR(int id, const FuncPrototype &proto) {
    // TODO: return value undefined because of aggregated type
    string async_template = R"XXXXX(
define i8* @digo_linker_async_call_id_#<id>#(#<arg_def>#) {
entry:
  %wrapper = call i8* @SW_CreateWrapper()

  #<arg_serialization>#

  %result = alloca i8*, align 8
  %len = alloca i32, align 4

  call void @SW_GetAndDestroy(i8* %wrapper, i8** %result, i32* %len)

  %result_in = load i8*, i8** %result, align 8
  %len_in = load i32, i32* %len, align 4

  %future_obj = call i8* @CreateAsyncJob(i32 0, i8* %result_in, i32 %len_in)

  ret i8* %future_obj
}

define i32 @digo_linker_await_id_#<id>#(i8* %arg_future_obj) {
  %result = alloca i8*, align 8
  %len = alloca i32, align 4
  call void @AwaitJob(i8* %arg_future_obj, i8** %result, i32* %len)

  %result_in = load i8*, i8** %result, align 8
  %len_in = load i32, i32* %len, align 4

  %extractor = call i8* @SW_CreateExtractor(i8* %result_in, i32 %len_in)

  #<ret_extractor>#

  call void @SW_DestroyExtractor(i8* %extractor)

  ret i32 %ret0
}
)XXXXX";

    async_template = regex_replace(async_template, regex("\\{"), "{{");
    async_template = regex_replace(async_template, regex("\\}"), "}}");
    async_template = regex_replace(async_template, regex("#<([a-z_]+)>#"), "{$1}");

    auto result = fmt::format(async_template, fmt::arg("id", id),
    fmt::arg("arg_serialization", GenerateSerializer(proto.parameters)),
    fmt::arg("arg_def", GenerateArgumentsDef(proto.parameters)),
    fmt::arg("ret_extractor", GenerateExtractor(proto.return_type, "ret")));

    return result;
}

string Metadata::GenerateAsyncCalls() {
    string result;

    for (int i = 0; i < functions_prototype_.size(); i++) {
        if (functions_prototype_[i].is_remote == 0)
            result += GenerateAsyncAsLLVMIR(i, functions_prototype_[i]);
        else
            //TODO:
            ;
    }

    return result;
}

string Metadata::GenerateDeclare() {
    string declare_template = R"XXXXX(

declare dso_local void @AwaitJob(i8*, i8**, i32*)
declare dso_local void @JobDecRef(i8*)
declare dso_local i8* @CreateAsyncJob(i32, i8*, i32)

declare dso_local i8* @SW_CreateWrapper()
declare dso_local void @SW_AddString(i8*, i8*)
declare dso_local void @SW_AddInt32(i8*, i32)
declare dso_local void @SW_AddInt64(i8*, i64)
declare dso_local void @SW_GetAndDestroy(i8*, i8**, i32*)

declare dso_local i8* @SW_CreateExtractor(i8*, i32)
declare dso_local i32 @SW_ExtractInt32(i8*)
declare dso_local i64 @SW_ExtractInt64(i8*)
declare dso_local i8* @SW_ExtractString(i8*)
declare dso_local void @SW_DestroyExtractor(i8*)

declare dso_local void @NoMatchExceptionHandler(i32 %func_id)
declare dso_local void @ASYNC_AddFunction(i32, i8* nocapture readonly)

declare dso_local void @Debug_Real_LinkerCallFunction(i32, i32)

)XXXXX";

    return declare_template;
}

std::tuple<string, string> Metadata::GenerateFuncNameIdMap(int id, const FuncPrototype &proto) {
    string str_name = "@.str.digo.linker.async.func.name" + to_string(id);
    string str_bound = "[" + to_string(proto.func_name.size()+1) + " x i8]";
    string str = str_name +
            " = private unnamed_addr constant " + str_bound +
            " c\"" + proto.func_name + "\\00\", align 1";
    string mapadd = "call void @ASYNC_AddFunction(i32 " + to_string(id) +
            ", i8* getelementptr inbounds (" + str_bound +
            ", " + str_bound + "* " + str_name + ", i64 0, i64 0))";
    return {str, mapadd};
}

string Metadata::GenerateEntry() {
    string str_def;
    string result = R"XXXXX(

define void @init_async_function_table() {
  )XXXXX";

    for (int i = 0; i < functions_prototype_.size(); i++) {

        auto [str, mapadd] = GenerateFuncNameIdMap(i, functions_prototype_[i]);

        str_def += str + "\n";
        result += mapadd + "\n";
    }

    result +=
  R"XXXXX(
  ret void
}

define void @main() {
entry:
  call void @init_async_function_table()

  ret void
}
)XXXXX";
    return str_def + "\n\n" + result;
}
