#include <iostream>
#include <fstream>
#include "serialization.h"
#include "metadata.h"

using namespace std;

int test_serialization();
int metadata_parser_entry(const string && file);

int main() {
    test_serialization();
    metadata_parser_entry("../metadata_template.ll");
    return 0;
}

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
    auto result = s_ext.Extract(serialized);

    for (const auto& cell : result.extracted_cells) {
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