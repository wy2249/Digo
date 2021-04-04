#ifndef ASYNC_REMOTE_LIB_SRC_RESOURCE_H_
#define ASYNC_REMOTE_LIB_SRC_RESOURCE_H_

#include "common.h"
#include <memory>
#include <cstdint>

class DigoString {
 public:
  DigoString() = default;
  DigoString(const char *);
  DigoString(const string&);

  DigoString operator+ (const DigoString&);

  DigoString operator+ (const char*);

  int64_t Compare(const DigoString&);

  int64_t Size();
 private:
  string raw_data;

};

__attribute__((noinline)) shared_ptr<DigoString> CreateString(char*);

__attribute__((noinline)) shared_ptr<DigoString> CreateEmptyString();

__attribute__((noinline)) shared_ptr<DigoString> AddString(DigoString*, DigoString*);

__attribute__((noinline)) shared_ptr<DigoString> CloneString(DigoString*);

__attribute__((noinline)) int64_t CompareString(DigoString*, DigoString*);

__attribute__((noinline)) int64_t GetStringSize(DigoString*);


#endif //ASYNC_REMOTE_LIB_SRC_RESOURCE_H_
