#ifndef ASYNC_REMOTE_LIB_SRC_IOUTIL_H_
#define ASYNC_REMOTE_LIB_SRC_IOUTIL_H_

#include <iostream>

using std::istream;
using std::ifstream;

void* ReadStream(istream &in);

extern "C" {
  void *ReadFile(void* path);
};

#endif //ASYNC_REMOTE_LIB_SRC_IOUTIL_H_
