#include <cstring>

#include "dstring.h"

void* CreateString(const char* src) {
    return new DigoString(src);
}

void* CreateEmptyString() {
    return new DigoString();
}

void* AddString(void* vl,
                void* vr) {
    auto l = (DigoString*) vl;
    auto r = (DigoString*) vr;
    return new DigoString(
            *l + *r);
}

void* AddCString(void* vl, const char* r) {
    auto l = (DigoString*) vl;
    return new DigoString(
            *l + r);
}

void* CloneString(void* vsrc) {
    return new DigoString(((DigoString*)vsrc)->Data());
}

int64_t CompareString(void* vl,
                      void* vr) {
    auto l = (DigoString*) vl;
    auto r = (DigoString*) vr;
    return l->Compare(*r);
}

int64_t GetStringSize(void* vs) {
    auto s = (DigoString*) vs;
    return s->Size();
}

const char* GetCStr(void* vs) {
    auto s = (DigoString*) vs;
    return s->Data().c_str();
}

DigoString::DigoString(const char *src) {
  raw_data_ = src;
}

DigoString::DigoString(const string &src) {
  raw_data_ = src;
}

DigoString DigoString::operator+(const DigoString& r) const {
  return DigoString(this->raw_data_ + r.raw_data_);
}

DigoString DigoString::operator+(const char* r) const {
  return DigoString(this->raw_data_ + r);
}

int64_t DigoString::Compare(const DigoString& r) const {
  return strcmp(this->raw_data_.c_str(), r.raw_data_.c_str());
}

int64_t DigoString::Size() const {
  return this->raw_data_.length();
}

const string & DigoString::Data() const {
  return this->raw_data_;
}
