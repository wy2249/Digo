#ifndef ASYNC_REMOTE_LIB_SRC_DSTRING_H_
#define ASYNC_REMOTE_LIB_SRC_DSTRING_H_

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

#include "../../digo-linker/src/gc.h"

using DStrObject = DObject<DigoString>;

extern "C" {

DStrObject* CreateString(const char*);

DStrObject* CreateEmptyString();

DStrObject* AddString(DStrObject*, DStrObject*);

DStrObject* AddCString(DStrObject*, const char*);

DStrObject* CloneString(DStrObject*);

int64_t CompareString(DStrObject*, DStrObject*);

int64_t GetStringSize(DStrObject*);

const char* GetCStr(DStrObject*);

};



#endif //ASYNC_REMOTE_LIB_SRC_RESOURCE_H_
