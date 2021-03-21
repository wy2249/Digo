//
// Created by VM on 2021/3/21.
//

#include "serialization.h"
#include "serialization_wrapper.h"

void* SW_CreateWrapper() {
    try {
        return (void*)new Serialization();
    }
    catch (std::exception & e) {
        std::cout << "Serialization wrapper exception: " << e.what() << std::endl;
    }
    return nullptr;
}

void SW_AddInt32(void* w, int32_t n) {
    try {
        ((Serialization *) w)->AddInt32(n);
    }
    catch (std::exception & e) {
        std::cout << "Serialization wrapper exception: " << e.what() << std::endl;
    }
}

void SW_AddInt64(void* w, int64_t n) {
    try {
        ((Serialization*)w)->AddInt64(n);
    }
    catch (std::exception & e) {
        std::cout << "Serialization wrapper exception: " << e.what() << std::endl;
    }
}

void SW_AddString(void* w, char* n) {
    try {
        ((Serialization*)w)->AddString(string(n));
    }
    catch (std::exception & e) {
        std::cout << "Serialization wrapper exception: " << e.what() << std::endl;
    }
}

void SW_GetAndDestroy(void* w, byte** out_bytes, int32_t* out_length) {
    try {
        *out_bytes = ((Serialization*)w)->GetBytes();
        *out_length = ((Serialization*)w)->GetSize();
    }
    catch (std::exception & e) {
        std::cout << "Serialization wrapper exception: " << e.what() << std::endl;
    }
}

void SW_FreeArray(const char* b) {
    try {
        delete[] b;
    }
    catch (std::exception & e) {
        std::cout << "Serialization wrapper exception: " << e.what() << std::endl;
    }
}
