//
// Created by VM on 2021/3/25.
//

#include "metadata.h"
#include <iostream>
#include <fstream>

using namespace std;

int metadata_parser_entry(const string && file) {
    fstream s;
    s.open(file, ios::in);
    string ir;
    string tmp;
    while (getline(s, tmp)) {
        ir += tmp + "\n";
    }
    Metadata metadata;
    metadata.ParseFuncMetadataFromLLIR(ir);

    return 0;
}

int main() {
    metadata_parser_entry("../test/async.ll");
    return 0;
}
