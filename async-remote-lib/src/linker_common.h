#ifndef ASYNC_REMOTE_LIB_SRC_LINKER_COMMON_H_
#define ASYNC_REMOTE_LIB_SRC_LINKER_COMMON_H_

#include "common.h"
#include "../../digo-linker/src/wrapper.h"

extern "C" {
__attribute__((noinline)) void linker_call_function(int32_t func_id, byte *content, int32 length,
                                                    byte **result, int32 *result_length);
}

inline bytes CallFunctionByName(string digo_func_name, bytes parameters) {
  byte *result;

  int32 result_length = 0;
  linker_call_function(ASYNC_GetFunctionId(digo_func_name.c_str()), parameters.content.get(), parameters.length,
                       &result, &result_length);
  return bytes{shared_ptr<byte>(result), result_length};
}

#endif //ASYNC_REMOTE_LIB_SRC_LINKER_COMMON_H_
