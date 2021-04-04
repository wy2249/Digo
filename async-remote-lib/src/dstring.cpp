#include <cstring>

#include "dstring.h"


__attribute__((noinline)) shared_ptr<DigoString> CreateString(const char* src) {
  return make_shared<DigoString>(DigoString(src));
}

__attribute__((noinline)) shared_ptr<DigoString> CreateEmptyString() {
  return make_shared<DigoString>(DigoString());
}

__attribute__((noinline)) shared_ptr<DigoString> AddString(const DigoString* l, const DigoString* r) {
  return make_shared<DigoString>(*l+*r);
}

__attribute__((noinline)) shared_ptr<DigoString> AddCString(const DigoString* l, const char* r) {
  return make_shared<DigoString>(*l+r);
}

__attribute__((noinline)) shared_ptr<DigoString> CloneString(const DigoString* src) {
  return make_shared<DigoString>(DigoString(*src));
}

__attribute__((noinline)) int64_t CompareString(const DigoString* l, const DigoString* r) {
  return l->Compare(*r);
}

__attribute__((noinline)) int64_t GetStringSize(const DigoString* s) {
  return s->Size();
}

__attribute__((noinline)) const char* GetCStr(const DigoString* s) {
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
