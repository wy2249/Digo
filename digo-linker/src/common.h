
#ifndef DIGO_LINKER_COMMON_H_
#define DIGO_LINKER_COMMON_H_

#include <string>
#include <memory>
#include <map>
#include <iostream>

using std::string;
typedef unsigned char byte;

class noncopyable {
 protected:
  noncopyable() = default;
  ~noncopyable() = default;

 public:
  noncopyable(const noncopyable &) = delete;
  noncopyable &operator=(const noncopyable &) = delete;
};

#endif //DIGO_LINKER_COMMON_H_
