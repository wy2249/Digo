//
// Created by VM on 2021/3/25.
//

#include "metadata.h"
#include <iostream>
#include <fstream>

using namespace std;

int generate_async_call_entry(const string& input_file, const string& output_file) {
    fstream s;
    s.open(input_file, ios::in);
    string ir;
    string tmp;
    while (getline(s, tmp)) {
        ir += tmp + "\n";
    }
    Metadata metadata;
    metadata.ParseFuncMetadataFromLLIR(ir);

    fstream output;
    output.open(output_file, ios::out);

    output << R"XXXXX(
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"
    )XXXXX";

    output << metadata.GenerateDeclare();
    output << metadata.GenerateAsyncCalls();
    output << metadata.GenerateJumpTable();
    output << metadata.GenerateEntry();

    return 0;
}

int main(int argc,char *argv[]) {
    if (argc != 4) return 1;
    string command = argv[1];
    string input_file = argv[2];
    string output_file = argv[3];
    if (command == "async") {
        generate_async_call_entry(input_file, output_file);
    } else {
        return 1;
    }
    return 0;
}
