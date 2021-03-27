#include <iostream>
#include <fstream>
#include "serialization.h"
#include "metadata.h"
#include "wrapper.h"

using namespace std;

int test_serialization();
int generate_async_call_entry(const string && input_file, const string && output_file);

int main() {
    //test_serialization();
    generate_async_call_entry("../../linker-test.ll", "../../test.ll.output");
    return 0;
}

int generate_async_call_entry(const string && input_file, const string && output_file) {
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

    output << metadata.GenerateDeclare();
    output << metadata.GenerateAsyncCalls();
    output << metadata.GenerateJumpTable();
    output << metadata.GenerateEntry();

    return 0;
}

int test_serialization() {
    Serialization s;
    s.AddInt32(100);
    s.AddInt64(200);
    auto str = "12345-- -- -- && TEST -- --- /*9*---* **d//s*;;;;;;;;~~`1````1";
    auto str2 = "22345-- -- -- && TEST -- --- /*9*---* **d//s*;;;;;;;;~~`1````1";
    s.AddString(str);
    s.AddString(str2);
    s.AddInt32(INT32_MAX);
    s.AddInt32(INT32_MIN);
    s.AddInt64(INT64_MAX);
    s.AddInt64(INT64_MIN);

    auto serialized = s.Get();

    Serialization s_ext;
    s_ext.Extract(serialized);

    for (const auto& cell : s_ext.GetResult().extracted_cells) {
        std::cout << "TypeCell: " << cell.type << " content: ";
        switch(cell.type) {
            case TYPE_STR:
                std::cout << cell.str;
                break;
            case TYPE_INT32:
                std::cout << cell.num32;
                break;
            case TYPE_INT64:
                std::cout << cell.num64;
                break;
            default:
                std::cout << "error!";
        }
        std::cout << std::endl;
    }

    return 0;
}
