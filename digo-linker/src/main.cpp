#include <iostream>
#include "serialization.h"

int test_serialization();

int main() {
    test_serialization();
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
        std::cout << "cell: " << cell.type << " content: ";
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