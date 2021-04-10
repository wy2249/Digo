//
// Created by VM on 2021/3/21.
//

#ifndef DIGO_LINKER_SERIALIZATION_WRAPPER_H
#define DIGO_LINKER_SERIALIZATION_WRAPPER_H

#include <cstdint>
typedef unsigned char byte;

extern "C" {
    void* SW_CreateWrapper();
    void SW_AddInt32(void*, int32_t);
    void SW_AddInt64(void*, int64_t);
    void SW_AddDouble(void*, double);
    void SW_AddString(void*, void* strWrapper);
    void SW_AddSlice(void*, void*);
    void SW_GetAndDestroy(void* w, byte** out_bytes, int32_t* out_length);
    void SW_FreeArray(const byte*);

    void* SW_CreateExtractor(byte*, int);
    int32_t SW_ExtractInt32(void*);
    int64_t SW_ExtractInt64(void*);
    double SW_ExtractDouble(void*);
    void* SW_ExtractString(void*);
    void* SW_ExtractSlice(void*);
    void SW_DestroyExtractor(void*);
}

#endif //DIGO_LINKER_SERIALIZATION_WRAPPER_H
