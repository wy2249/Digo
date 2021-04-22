#ifndef ASYNC_REMOTE_LIB_SRC_DSTRING_H_
#define ASYNC_REMOTE_LIB_SRC_DSTRING_H_

#include "common.h"
#include <memory>
#include <cstdint>
#include "../../digo-linker/src/gc.h"

class DigoString : public DObject {
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

extern "C" {

void* CreateString(const char*);

void* CreateEmptyString();

void* AddString(void*, void*);

void* AddCString(void*, const char*);

void* CloneString(void*);

int64_t CompareString(void*, void*);

int64_t GetStringSize(void*);

const char* GetCStr(void*);

}



#endif //ASYNC_REMOTE_LIB_SRC_RESOURCE_H_
