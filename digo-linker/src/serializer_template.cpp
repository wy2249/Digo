//
// Created by VM on 2021/3/21.
//

#include "serialization_wrapper.h"

int serializer_template(char* str, char* str2) {
    void* s = SW_CreateWrapper();
    SW_AddInt32(s, 100);
    SW_AddInt32(s, 100);
    SW_AddInt64(s, 200);
    SW_AddString(s, str);
    SW_AddString(s, str2);
    SW_AddInt32(s, INT32_MAX);
    SW_AddInt32(s, INT32_MIN);
    SW_AddInt64(s, INT64_MAX);
    SW_AddInt64(s, INT64_MIN);

    byte* result = nullptr;
    int len = 0;

    SW_GetAndDestroy(s, &result, &len);
    return 0;
}
