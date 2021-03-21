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
    void SW_AddString(void*, char*);
    void SW_GetAndDestroy(void* w, byte** out_bytes, int32_t* out_length);
    void SW_FreeArray(const char*);

    // TODO:
    void SW_Extract();
}

#endif //DIGO_LINKER_SERIALIZATION_WRAPPER_H
