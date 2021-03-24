#ifndef ASYNC_REMOTE_LIB_SRC_UTILS_C_
#define ASYNC_REMOTE_LIB_SRC_UTILS_C_

#include <stdio.h>

__attribute__((noinline)) void printFloat(float f) {
  printf("%.lf\n", f);
}

__attribute__((noinline)) void printInt(int i) {
  printf("%d\n", i);
}

__attribute__((noinline)) void printString(char *s) {
  printf("%s\n", s);
}
#endif //ASYNC_REMOTE_LIB_SRC_UTILS_C_
