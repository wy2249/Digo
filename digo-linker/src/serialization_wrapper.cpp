//
// Created by VM on 2021/3/21.
//

#include "serialization.h"
#include "serialization_wrapper.h"

void* SW_CreateWrapper() {
    return (void*)new Serialization();
}

void SW_AddInt32(void* w, int32_t n) {
    ((Serialization*)w)->AddInt32(n);
}

void SW_AddInt64(void* w, int64_t n) {
    ((Serialization*)w)->AddInt64(n);
}

void SW_AddString(void* w, char* n) {
    ((Serialization*)w)->AddString(string(n));
}

void SW_GetAndDestroy(void* w, byte** out_bytes, int32_t* out_length) {
    *out_bytes = ((Serialization*)w)->GetBytes();
    *out_length = ((Serialization*)w)->GetSize();
}

void SW_FreeArray(const char* b) {
    delete[] b;
}
