#ifndef ASYNC_REMOTE_LIB_SRC_RESOURCE_H_
#define ASYNC_REMOTE_LIB_SRC_RESOURCE_H_

#include "common.h"
#include <memory>
#include <cstdint>

class DigoString {
 public:
  DigoString() = default;
  explicit DigoString(const char *);
  explicit DigoString(const string&);

  DigoString operator+ (const DigoString&) const;

  DigoString operator+ (const char*) const;

  const string &Data() const;

  int64_t Compare(const DigoString&) const;

  int64_t Size() const;

 private:
  string raw_data_;

};

shared_ptr<DigoString> CreateString(const char*);

shared_ptr<DigoString> CreateEmptyString();

shared_ptr<DigoString> AddString(const DigoString*, const DigoString*);

shared_ptr<DigoString> AddCString(const DigoString*, const char*);

shared_ptr<DigoString> CloneString(const DigoString*);

int64_t CompareString(const DigoString*, const DigoString*);

int64_t GetStringSize(const DigoString*);

const char* GetCStr(const DigoString*);


#endif //ASYNC_REMOTE_LIB_SRC_RESOURCE_H_
