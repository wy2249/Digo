//
// Created by VM on 2021/3/21.
//

#include "serialization_wrapper.h"
#include <string.h>
#include <stdarg.h>

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

    SW_FreeArray(result);
    return 0;
}

// see https://llvm.org/docs/LangRef.html#variable-argument-handling-intrinsics

void jump_table_template(const char* func_name, ...) {
    int parameter_count = 0;
    if (strcmp("func1", func_name) == 0) {
        parameter_count = 5;
        goto func1;
    }

    func1:
    va_list args;
    va_start(args, func_name);
    for (int i = 0; i < parameter_count; i++) {
        va_arg(args, int64_t);
        va_arg(args, char*);
    }

    va_end(args);

    goto end;

    end:
    return;
}
