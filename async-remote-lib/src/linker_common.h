#ifndef ASYNC_REMOTE_LIB_LINKER_COMMON_H
#define ASYNC_REMOTE_LIB_LINKER_COMMON_H

#include "common.h"

extern "C" {
    __attribute__((noinline)) void linker_call_function(const char* digo_func_name, byte* content, int32 length,
                                                    byte** result, int32* result_length);
}

inline bytes CallFunctionByName(string digo_func_name, bytes parameters) {
    byte* result = nullptr;
    int32 result_length = 0;
    linker_call_function(digo_func_name.c_str(), parameters.content.get(), parameters.length,
                           &result, &result_length);
    return bytes{shared_ptr<byte>(result), result_length};
}

#endif //ASYNC_REMOTE_LIB_LINKER_COMMON_H
