
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef int32_t int32;
typedef unsigned char byte;

__attribute__((noinline)) void linker_call_function(int32_t func_id, byte *content, int32 length,
                                                    byte **result, int32 *result_length) {
  // hack here.
  printf("Warning: if you are seeing this, the linker is not ready !!!!\n");

  *result = malloc(length);
  memcpy(*result, content, length);
  *result_length = length;
}

__attribute__((noinline)) int32 ASYNC_GetFunctionId(const char* func_name) {
    return 0;
}
