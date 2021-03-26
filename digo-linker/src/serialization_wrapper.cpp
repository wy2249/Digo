//
// Created by VM on 2021/3/21.
//

#include <unistd.h>
#include "serialization.h"
#include "serialization_wrapper.h"

#include "gc.h"
#include "wrapper.h"

static void SerializationExceptionHandler(const std::string& func, std::exception & e) noexcept {
    std::cout << "Serialization wrapper exception: " << typeid(e).name() << " " << e.what() << " caught in function " << func << std::endl;
    sleep(5);
    exit(1);
}

static void ExtractorExceptionHandler(const std::string& func, std::exception & e) noexcept {
    std::cout << "Serialization extractor exception: " << typeid(e).name() << " " << e.what() << " caught in function " << func  << std::endl;
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

void SW_AddString(void* w, char* n) {
    try {
        ((Serialization*)w)->AddString(string(n));
    }
    catch (std::exception & e) {
        SerializationExceptionHandler("SW_AddString", e);
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

void SW_DestroyExtractor(void* s) {
    auto se = (Serialization*)s;
    delete se;
}
