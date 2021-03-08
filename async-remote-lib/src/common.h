
#ifndef ASYNC_REMOTE_LIB_COMMON_H
#define ASYNC_REMOTE_LIB_COMMON_H

#include <string>
#include <memory>
using std::string;
using std::shared_ptr;

typedef int32_t int32;
typedef int future_obj_ptr;
typedef unsigned char byte;

typedef struct bytes {
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

#endif //ASYNC_REMOTE_LIB_COMMON_H
