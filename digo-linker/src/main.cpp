#include <iostream>
#include <fstream>
#include <cmath>
#include "serialization.h"
#include "metadata.h"
#include "wrapper.h"
#include "serialization_wrapper.h"
#include "builtin_types.h"

using namespace std;

int test_serialization();
int test_serialization2();
int generate_async_call_entry(const string& input_file, const string& output_file);

int main() {
    test_serialization2();
    return 0;

    string command = "async";
    string input_file = "../../digo-linker/test/test-async-2.ll";
    string output_file = "../../digo-linker/test/test-async-2.ll.out";
    if (command == "async") {
        generate_async_call_entry(input_file, output_file);
    } else {
        return 1;
    }
    return 0;
}

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

    output << metadata.GenerateDeclare();
    output << metadata.GenerateAsyncCalls();
    output << metadata.GenerateJumpTable();
    output << metadata.GenerateEntry();

    return 0;
}

void print_slice(const vector<TypeCell> & arr) {
    std::cout << " slice with size " << arr.size() << ": ";
    for (int i = 0; i < arr.size(); i++) {
        auto cell = arr[i];
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
            case TYPE_DOUBLE:
                std::cout << cell.num_double;
                break;
            default:
                std::cout << "error!";
        }
        std::cout << " | ";
    }
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
    s.AddDouble(10.403);
    s.AddDouble(sqrt(-1));
    s.AddDouble(log(-1));
    s.AddDouble(1 / 0.0);
    s.AddDouble(-1 / 0.0);
    s.AddDouble(-10.0);
    s.AddSlice({TypeCell("1234-EST -- --- /*9*---* **d//s*;;;;;;;;~~`1"),
                TypeCell("2234-EST -- --- /*9*---* **d//s*;;;223;;;;;~~`1"),
                TypeCell("1234")}, TYPE_STR);
    /*  mixed type is only for test purpose  */
    s.AddSlice({TypeCell(-23.403),
                TypeCell("2234-"),
                TypeCell(100203033)}, TYPE_STR);
    s.AddDouble(-102222222.1);

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
            case TYPE_DOUBLE:
                std::cout << cell.num_double;
                break;
            case TYPE_SLICE:
                print_slice(cell.arr);
                break;
            default:
                std::cout << "error!";
        }
        std::cout << std::endl;
    }

    return 0;
}

int test_serialization2() {
    DStrObject * strobj = static_cast<DStrObject *>(CreateString("12343134"));


    void * obj = SW_CreateWrapper();
    void * slice = CreateSlice(TYPE_STR);
    DSliObject * slice2 = static_cast<DSliObject *>(SliceAppend(slice, strobj));

    SW_AddSlice(obj, slice2);

    ::byte* result;
    int len;
    SW_GetAndDestroy(obj, &result, &len);

    void * ext = SW_CreateExtractor(result, len);
    void * slice_out;
    slice_out = SW_ExtractSlice(ext);

    DSliObject * conv = (DSliObject*)slice_out;

    DStrObject  * strObject = static_cast<DStrObject *>((std::get<0>(conv->Get()->Data()).at(0)).str_obj);

    return 0;
}
