
#ifndef ASYNC_REMOTE_LIB_SRC_COMMON_H_
#define ASYNC_REMOTE_LIB_SRC_COMMON_H_

#include <string>
#include <memory>
#include <map>
#include <iostream>

using std::string;
using std::shared_ptr;
using std::map;
using std::to_string;
using std::cout;
using std::cerr;
using std::endl;
using std::make_shared;

typedef int32_t int32;
typedef int future_obj_ptr;
typedef unsigned char byte;

typedef struct bytes {
  // FIXME: memory leak when destructing content
  shared_ptr<byte> content = nullptr;
  int32 length = 0;
} bytes;

class noncopyable {
 protected:
  noncopyable() = default;
  ~noncopyable() = default;

 public:
  noncopyable(const noncopyable &) = delete;
  noncopyable &operator=(const noncopyable &) = delete;
};

#endif //ASYNC_REMOTE_LIB_SRC_COMMON_H_
