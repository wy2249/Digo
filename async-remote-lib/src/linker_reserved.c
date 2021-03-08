
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef int32_t int32;
typedef unsigned char byte;

__attribute__((noinline)) void linker_call_function(const char *digo_func_name, byte *content, int32 length,
                                                    byte **result, int32 *result_length) {
  // hack here.
  printf("if you are seeing this, the digo linker is ready!\n");
  printf("you are calling: %s\n", digo_func_name);

  *result = malloc(length);
  memcpy(*result, content, length);
  *result_length = length;
}
