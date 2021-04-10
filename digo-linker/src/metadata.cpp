//
// Created by VM on 2021/3/21.
//

#include "metadata.h"
#include <regex>
#include <sstream>
#include <utility>

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
    IncorrectMetadataException(): msg("incorrect metadata") {}
    IncorrectMetadataException(string m): msg(std::move(m)) {}
    const char * what() const noexcept override {
        return msg.c_str();
    }
private:
    string msg;
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
            throw IncorrectMetadataException("async/async remote expected");
        }

        prototype.func_name = func_name;
        vector<string> p = split(parameters, ',');
        for(const string& str : p) {
            if (str == "int") {
                prototype.parameters.push_back(TYPE_INT64);
            } else if (str == "string") {
                prototype.parameters.push_back(TYPE_STR);
            } else if (str == "double") {
                prototype.parameters.push_back(TYPE_DOUBLE);
            } else if (str == "slice") {
                prototype.parameters.push_back(TYPE_SLICE);
            } else {
                throw IncorrectMetadataException("wrong parameter type");
            }
        }

        p = split(return_type, ',');

        for(const string& str : p) {
            if (str == "int") {
                prototype.return_type.push_back(TYPE_INT64);
            } else if (str == "string") {
                prototype.return_type.push_back(TYPE_STR);
            } else if (str == "double") {
                prototype.return_type.push_back(TYPE_DOUBLE);
            } else if (str == "slice") {
                prototype.return_type.push_back(TYPE_SLICE);
            } else {
                throw IncorrectMetadataException("wrong return type");
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
    string label_template = R"XXXXX(
if.func#<id>#:
  #<arg_extractor>#
  %aggResult#<id># = call #<ret_type># @#<func_name>#(#<arguments>#)
#<ret_serializer>#
  call void @SW_GetAndDestroy(i8* %wrapper, i8** %result, i32* %result_len)

  br label %if.end
)XXXXX";

    label_template = regex_replace(label_template, regex("\\{"), "{{");
    label_template = regex_replace(label_template, regex("\\}"), "}}");
    label_template = regex_replace(label_template, regex("#<([a-z_]+)>#"), "{$1}");

    string ret_type = "{ " + GenerateArgumentsType(proto.return_type) + " }";

    auto result = fmt::format(label_template, fmt::arg("id", id),
                              fmt::arg("func_name", proto.func_name),
                              fmt::arg("ret_type", ret_type),
                              fmt::arg("arguments", GenerateArgumentsDef(proto.parameters)),
                              fmt::arg("arg_extractor", GenerateExtractor(proto.parameters, "arg")),
                              fmt::arg("ret_serializer",
                                       GenerateSerializerAggregated(proto.return_type,
                                                                    "%aggResult" + to_string(id))));
    return result;
}

// serialize %<prefix>0, 1, ...
string Metadata::GenerateSerializer(const vector<digo_type> & types, const string & prefix) {
    string result;
    for (int i = 0; i < types.size(); i++) {
        auto type = types[i];
        if (type == TYPE_INT32) {
            result += R"(
  call void @SW_AddInt32(i8* %wrapper, i32 %)" + prefix + to_string(i) + ")";
        } else if (type == TYPE_INT64) {
            result += R"(
  call void @SW_AddInt64(i8* %wrapper, i64 %)" + prefix + to_string(i) + ")";
        } else if (type == TYPE_STR) {
            result += R"(
  call void @SW_AddString(i8* %wrapper, i8* %)" + prefix + to_string(i) + ")";
        } else if (type == TYPE_SLICE) {
            result += R"(
  call void @SW_AddSlice(i8* %wrapper, i8* %)" + prefix + to_string(i) + ")";
        } else if (type == TYPE_DOUBLE) {
            result += R"(
  call void @SW_AddDouble(i8* %wrapper, double %)" + prefix + to_string(i) + ")";
        }
    }
    return result;
}

// serialize an aggregate type, agg_name should include "%"
string Metadata::GenerateSerializerAggregated(const vector<digo_type> & types, const string & agg_name) {
    string result;
    int auto_inc_reg = 0;
    string agg_type = "{ " + GenerateArgumentsType(types) + " }";

    string extract_value_template =
            "  {to_reg} = extractvalue {agg_type} " + agg_name + ", {i}\n";

    for (int i = 0; i < types.size(); i++) {
        auto type = types[i];
        string reg = "%tmp_" + to_string(auto_inc_reg++);
        if (type == TYPE_INT32) {
            result += fmt::format(extract_value_template,
                                  fmt::arg("to_reg", reg),
                                  fmt::arg("agg_type", agg_type),
                                  fmt::arg("i", i));
            result += R"(
  call void @SW_AddInt32(i8* %wrapper, i32 )" + reg + ")\n";
        } else if (type == TYPE_INT64) {
            result += fmt::format(extract_value_template,
                                  fmt::arg("to_reg", reg),
                                  fmt::arg("agg_type", agg_type),
                                  fmt::arg("i", i));
            result += R"(
  call void @SW_AddInt64(i8* %wrapper, i64 )" + reg + ")\n";
        } else if (type == TYPE_STR) {
            result += fmt::format(extract_value_template,
                                  fmt::arg("to_reg", reg),
                                  fmt::arg("agg_type", agg_type),
                                  fmt::arg("i", i));
            result += R"(
  call void @SW_AddString(i8* %wrapper, i8* )" + reg + ")\n";
        } else if (type == TYPE_SLICE) {
            result += fmt::format(extract_value_template,
                                  fmt::arg("to_reg", reg),
                                  fmt::arg("agg_type", agg_type),
                                  fmt::arg("i", i));
            result += R"(
  call void @SW_AddSlice(i8* %wrapper, i8* )" + reg + ")\n";
        } else if (type == TYPE_DOUBLE) {
            result += fmt::format(extract_value_template,
                                  fmt::arg("to_reg", reg),
                                  fmt::arg("agg_type", agg_type),
                                  fmt::arg("i", i));
            result += R"(
  call void @SW_AddDouble(i8* %wrapper, double )" + reg + ")\n";
        }
    }
    return result;
}

// each item extracted is stored in %<padding>0, 1, ...
string Metadata::GenerateExtractor(const vector<digo_type> & types, const string& padding) {
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
        } else if (type == TYPE_SLICE) {
            result += R"(
  %)" + padding + to_string(i) +  R"( = call i8* @SW_ExtractSlice(i8* %extractor)
)";
        } else if (type == TYPE_DOUBLE) {
            result += R"(
  %)" + padding + to_string(i) +  R"( = call double @SW_ExtractDouble(i8* %extractor)
)";
        }
    }
    return result;
}

// type list. e.g. i8, i32, i8* ....
string Metadata::GenerateArgumentsType(const vector<digo_type> &types) {
    string result;
    if (types.empty()) return result;
    for (int i = 0; i < types.size(); i++) {
        auto type = types[i];
        if (type == TYPE_INT32) {
            result += R"(i32, )";
        } else if (type == TYPE_INT64) {
            result += R"(i64, )";
        } else if (type == TYPE_STR) {
            result += R"(i8*, )";
        } else if (type == TYPE_SLICE) {
            result += R"(i8*, )";
        } else if (type == TYPE_DOUBLE) {
            result += R"(double, )";
        }
    }
    result = result.substr(0, result.length() - 2);
    return result;
}

// each argument is named %arg0, %arg1, ...
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
        } else if (type == TYPE_SLICE) {
            result += R"(i8* %arg)" + to_string(i) + ", ";
        } else if (type == TYPE_DOUBLE) {
            result += R"(double %arg)" + to_string(i) + ", ";
        }
    }
    result = result.substr(0, result.length() - 2);
    return result;
}

string Metadata::GenerateAsyncAsLLVMIR(int id, const FuncPrototype &proto) {
    string async_template = R"XXXXX(
define i8* @digo_linker_async_call_func_#<func_name>#(#<arg_def>#) {
  %call = call i8* @digo_linker_async_call_id_#<id>#(#<arg_def>#)
  ret i8* %call
}

define i8* @digo_linker_async_call_id_#<id>#(#<arg_def>#) {
entry:
  %wrapper = call i8* @SW_CreateWrapper()

  #<arg_serialization>#

  %result = alloca i8*, align 8
  %len = alloca i32, align 4

  call void @SW_GetAndDestroy(i8* %wrapper, i8** %result, i32* %len)

  %result_in = load i8*, i8** %result, align 8
  %len_in = load i32, i32* %len, align 4

  %future_obj = call i8* @#<job_call>#(i32 0, i8* %result_in, i32 %len_in)

  ret i8* %future_obj
}

define #<ret_type_list># @digo_linker_await_func_#<func_name>#(i8* %arg_future_obj) {
  %call = call #<ret_type_list># @digo_linker_await_id_#<id>#(i8* %arg_future_obj)
  ret #<ret_type_list># %call
}

define #<ret_type_list># @digo_linker_await_id_#<id>#(i8* %arg_future_obj) {
  %result = alloca i8*, align 8
  %len = alloca i32, align 4
  call void @AwaitJob(i8* %arg_future_obj, i8** %result, i32* %len)

  %result_in = load i8*, i8** %result, align 8
  %len_in = load i32, i32* %len, align 4

  %extractor = call i8* @SW_CreateExtractor(i8* %result_in, i32 %len_in)

  #<ret_extractor>#

  call void @SW_DestroyExtractor(i8* %extractor)

#<ret_formation>#

  ret #<ret_type_list># %aggRet
}
)XXXXX";

    async_template = regex_replace(async_template, regex("\\{"), "{{");
    async_template = regex_replace(async_template, regex("\\}"), "}}");
    async_template = regex_replace(async_template, regex("#<([a-z_]+)>#"), "{$1}");

    string ret_formation;
    string ret_type = "{ " + GenerateArgumentsType(proto.return_type) + " }";

    string ret_formation_template = "  {this_var} = insertvalue {ret_type} {last_var}, {this_type} %ret{i}, {i}\n";

    for (int i = 0; i < proto.return_type.size(); i++) {
        string last_var = "undef";
        if (i > 0) last_var = "%ret_agg_" + to_string(i - 1);
        string this_var = "%ret_agg_" + to_string(i);
        if (i == (int)proto.return_type.size() - 1) this_var = "%aggRet";

        string this_type;
        auto type = proto.return_type[i];
        if (type == TYPE_INT32) {
            this_type = "i32";
        } else if (type == TYPE_INT64) {
            this_type = "i64";
        } else if (type == TYPE_STR) {
            this_type = "i8*";
        } else if (type == TYPE_SLICE) {
            this_type = "i8*";
        } else if (type == TYPE_DOUBLE) {
            this_type = "double";
        }

        ret_formation += fmt::format(ret_formation_template, fmt::arg("this_var", this_var),
                                     fmt::arg("ret_type", ret_type),
                                     fmt::arg("last_var", last_var),
                                     fmt::arg("this_type", this_type),
                                     fmt::arg("i", i));
    }

    auto result = fmt::format(async_template, fmt::arg("id", id),
    fmt::arg("arg_serialization", GenerateSerializer(proto.parameters, "arg")),
    fmt::arg("arg_def", GenerateArgumentsDef(proto.parameters)),
    fmt::arg("ret_type_list", ret_type),
    fmt::arg("ret_extractor", GenerateExtractor(proto.return_type, "ret")),
    fmt::arg("func_name", proto.func_name),
    fmt::arg("job_call", proto.is_remote ? "CreateRemoteJob" : "CreateAsyncJob"),
    fmt::arg("ret_formation", ret_formation));

    return result;
}

string Metadata::GenerateAsyncCalls() {
    string result;

    for (int i = 0; i < functions_prototype_.size(); i++) {
        result += GenerateAsyncAsLLVMIR(i, functions_prototype_[i]);
    }

    return result;
}

string Metadata::GenerateDeclare() {
    string declare_template = R"XXXXX(

declare dso_local i8* @CreateString(i8*)
declare dso_local i8* @CreateEmptyString()
declare dso_local i8* @AddString(i8*, i8*)
declare dso_local i8* @AddCString(i8*, i8*)
declare dso_local i8* @CloneString(i8*)
declare dso_local i64 @CompareString(i8*, i8*)
declare dso_local i64 @GetStringSize(i8*)
declare dso_local i8* @GetCStr(i8*)

declare dso_local void @print(i8*, ...)
declare dso_local void @println(i8*, ...)

declare dso_local i8* @CreateSlice(i64)
declare dso_local i8* @SliceSlice(i8*, i64, i64)
declare dso_local i8* @SliceAppend(i8*, ...)
declare dso_local i8* @CloneSlice(i8*)
declare dso_local i64 @GetSliceSize(i8*)

declare dso_local void @AwaitJob(i8*, i8**, i32*)
declare dso_local void @JobDecRef(i8*)
declare dso_local i8* @CreateAsyncJob(i32, i8*, i32)
declare dso_local i8* @CreateRemoteJob(i32, i8*, i32)

declare dso_local i8* @SW_CreateWrapper()
declare dso_local void @SW_AddString(i8*, i8*)
declare dso_local void @SW_AddInt32(i8*, i32)
declare dso_local void @SW_AddInt64(i8*, i64)
declare dso_local void @SW_AddDouble(i8*, double)
declare dso_local void @SW_AddSlice(i8*, i8*)
declare dso_local void @SW_GetAndDestroy(i8*, i8**, i32*)

declare dso_local i8* @SW_CreateExtractor(i8*, i32)
declare dso_local i32 @SW_ExtractInt32(i8*)
declare dso_local i64 @SW_ExtractInt64(i8*)
declare dso_local double @SW_ExtractDouble(i8*)
declare dso_local i8* @SW_ExtractString(i8*)
declare dso_local i8* @SW_ExtractSlice(i8*)
declare dso_local void @SW_DestroyExtractor(i8*)

declare dso_local void @NoMatchExceptionHandler(i32 %func_id)
declare dso_local void @ASYNC_AddFunction(i32, i8*)

declare dso_local i32 @entry(i32, i8**)

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

define i32 @main(i32 %argc, i8** %argv) {
entry:
  call void @init_async_function_table()

  %morw = call i32 @entry(i32 %argc, i8** %argv)

  switch i32 %morw, label %if.worker [
    i32 1, label %if.master
    i32 2, label %if.worker
  ]

if.master:
  call void @digo_main()
  ret i32 0

if.worker:
  ret i32 0
}
)XXXXX";
    return str_def + "\n\n" + result;
}
