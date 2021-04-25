/* The LLVM IR boundary wrapper for the Digo Serialization Library.
 * It provides serialization interface for each Digo type.
 * Compiler does not use these interfaces directly.
 * Instead, the details of serialization is hidden in the interfaces provided by Digo Linker.
 *
 * Author: sh4081
 * Date: 2021/3/21
 */

#include <unistd.h>
#include "serialization.h"
#include "serialization_wrapper.h"

#include "gc.h"
#include "builtin_types.h"

static void SerializationExceptionHandler(const std::string& func, std::exception & e) noexcept {
    std::cerr << "Serialization Error: wrapper exception: " << typeid(e).name() << " " << e.what() << " caught in function " << func << std::endl;
    sleep(5);
    exit(1);
}

static void ExtractorExceptionHandler(const std::string& func, std::exception & e) noexcept {
    std::cerr << "Serialization Error: extractor exception: " << typeid(e).name() << " " << e.what() << " caught in function " << func  << std::endl;
    sleep(5);
    exit(1);
}

void* SW_CreateWrapper() {
    try {
        return (void*)new Serialization();
    }
    catch (std::exception & e) {
        SerializationExceptionHandler("SW_CreateWrapper", e);
    }
    return nullptr;
}

void SW_AddInt32(void* w, int32_t n) {
    try {
        ((Serialization *) w)->AddInt32(n);
    }
    catch (std::exception & e) {
        SerializationExceptionHandler("SW_AddInt32", e);
    }
}

void SW_AddInt64(void* w, int64_t n) {
    try {
        ((Serialization*)w)->AddInt64(n);
    }
    catch (std::exception & e) {
        SerializationExceptionHandler("SW_AddInt64", e);
    }
}

void SW_AddDouble(void* w, double n) {
    try {
        ((Serialization*)w)->AddDouble(n);
    }
    catch (std::exception & e) {
        SerializationExceptionHandler("SW_AddDouble", e);
    }
}

void SW_AddString(void* wi, void* wj) {
    Serialization * w = (Serialization*)wi;
    DigoString * strWrapper = (DigoString*)wj;
    try {
        /*   unwrap here  */
        w->AddString(strWrapper->Data());
    }
    catch (std::exception & e) {
        SerializationExceptionHandler("SW_AddString", e);
    }
}

void SW_AddSlice(void* wi, void* wj) {
    Serialization * w = (Serialization*)wi;
    DigoSlice * sliceWrapper = (DigoSlice*)wj;
    try {
        if (sliceWrapper == nullptr) {
            // throw NullPointerException("Add a null slice");
        }
        /*   unwrap here  */
        /*   generates an array with necessary data only   */
        vector<TypeCell> arr;
        auto [underlying_arr, begin, end] = sliceWrapper->Data();
        digo_type sliceType = sliceWrapper->Type();
        arr.reserve(end - begin);
        for (auto i = begin; i < end; i++) {
            TypeCell cell = underlying_arr[i];
            if (sliceType == TYPE_STR) {
                cell.str = ((DigoString*)(cell.str_obj))->Data();
            }
            cell.type = sliceType;
            arr.push_back(cell);
        }
        w->AddSlice(arr, sliceType);
    }
    catch (std::exception & e) {
        SerializationExceptionHandler("SW_AddSlice", e);
    }
}

void SW_GetAndDestroy(void* w, byte** out_bytes, int32_t* out_length) {
    try {
        *out_bytes = ((Serialization*)w)->GetBytes();
        *out_length = ((Serialization*)w)->GetSize();
        delete (Serialization*)w;
    }
    catch (std::exception & e) {
        SerializationExceptionHandler("SW_GetAndDestroy", e);
    }
}

void SW_FreeArray(const byte* b) {
    // delete never throws exceptions
    delete[] b;
}

void* SW_CreateExtractor(byte* stream, int len) {
    try {

        auto s = new Serialization();
        s->Extract(stream, len);

        return s;
    }
    catch (std::exception & e) {
        ExtractorExceptionHandler("SW_CreateExtractor", e);
    }
    return nullptr;
}

int32_t SW_ExtractInt32(void* s) {
    try {
        auto se = (Serialization*)s;
        auto cell = se->ExtractOne();
        if (cell.type != TYPE_INT32) {
            printf("Wrong extraction type\n");
            return -1;
        }
        return cell.num32;
    }
    catch (std::exception & e) {
        ExtractorExceptionHandler("SW_ExtractInt32", e);
    }
    return -1;
}

int64_t SW_ExtractInt64(void* s) {
    try {
        auto se = (Serialization*)s;
        auto cell = se->ExtractOne();
        if (cell.type != TYPE_INT64) {
            printf("Wrong extraction type\n");
            return -1;
        }
        return cell.num64;
    }
    catch (std::exception & e) {
        ExtractorExceptionHandler("SW_ExtractInt64", e);
    }
    return -1;
}

double SW_ExtractDouble(void* s) {
    try {
        auto se = (Serialization*)s;
        auto cell = se->ExtractOne();
        if (cell.type != TYPE_DOUBLE) {
            printf("Wrong extraction type\n");
            return -1;
        }
        return cell.num_double;
    }
    catch (std::exception & e) {
        ExtractorExceptionHandler("SW_ExtractDouble", e);
    }
    return -1;
}

void* SW_ExtractString(void* s) {
    try {
        auto se = (Serialization*)s;
        auto cell = se->ExtractOne();
        if (cell.type != TYPE_STR) {
            printf("Wrong extraction type\n");
            return nullptr;
        }
        return CreateString(cell.str.c_str());
    }
    catch (std::exception & e) {
        ExtractorExceptionHandler("SW_ExtractString", e);
    }
    return nullptr;
}

void* SW_ExtractSlice(void* s) {
    try {
        auto se = (Serialization*)s;
        auto cell = se->ExtractOne();
        if (cell.type != TYPE_SLICE) {
            printf("Wrong extraction type\n");
            return nullptr;
        }
        /*  wraps it to Digo Object  */
        auto sliceObj = new DigoSlice(cell.arr_slice_type);
        /*  directly set data  */
        auto [underlying_arr, begin, end] = sliceObj->Data();
        begin = 0; end = 0;
        for (int i = 0; i < (int)cell.arr.size(); i++) {
            auto nested_cell = cell.arr[i];
            if (cell.arr_slice_type == TYPE_STR) {
                /* wraps nested cell to Digo Object */
                nested_cell.str_obj = CreateString(nested_cell.str.c_str());
                nested_cell.str = "";
            }
            nested_cell.type = cell.arr_slice_type;
            underlying_arr.push_back(nested_cell);
            end++;
        }
        return sliceObj;
    }
    catch (std::exception & e) {
        ExtractorExceptionHandler("SW_ExtractString", e);
    }
    return nullptr;
}

void SW_DestroyExtractor(void* s) {
    auto se = (Serialization*)s;
    delete se;
}
