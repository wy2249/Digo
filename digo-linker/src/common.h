
#ifndef DIGO_LINKER_COMMON_H_
#define DIGO_LINKER_COMMON_H_

#include <string>
#include <memory>
#include <map>
#include <iostream>

using std::string;
typedef unsigned char byte;

enum digo_type {
    TYPE_UNDEFINED = 0,
    TYPE_STR = 1,
    TYPE_INT32 = 2,
    TYPE_INT64 = 3,
};

class TypeCell {
public:
    TypeCell() = default;
    explicit TypeCell(string s) : str(std::move(s)), type(TYPE_STR) {}
    explicit TypeCell(int32_t num) : num32(num), type(TYPE_INT32) {}
    explicit TypeCell(int64_t num) : num64(num), type(TYPE_INT64) {}
    digo_type type = TYPE_UNDEFINED;
    string   str;
    int32_t  num32 = 0;
    int64_t  num64 = 0;
};

class noncopyable {
 protected:
  noncopyable() = default;
  ~noncopyable() = default;

 public:
  noncopyable(const noncopyable &) = delete;
  noncopyable &operator=(const noncopyable &) = delete;
};

#endif //DIGO_LINKER_COMMON_H_
