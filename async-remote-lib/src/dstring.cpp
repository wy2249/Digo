#include <cstring>

#include "dstring.h"


__attribute__((noinline)) shared_ptr<DigoString> CreateString(char* src) {
  return make_shared<DigoString>(DigoString(src));
}

__attribute__((noinline)) shared_ptr<DigoString> CreateEmptyString() {
  return make_shared<DigoString>(DigoString());
}

__attribute__((noinline)) shared_ptr<DigoString> AddString(DigoString* l, DigoString* r) {
  return make_shared<DigoString>(*l+*r);
}

__attribute__((noinline)) shared_ptr<DigoString> CloneString(DigoString* src) {
  return make_shared<DigoString>(DigoString(*src));
}

__attribute__((noinline)) int64_t CompareString(DigoString* l, DigoString* r) {
  return l->Compare(*r);
}

__attribute__((noinline)) int64_t GetStringSize(DigoString* s) {
  return s->Size();
}

DigoString::DigoString(const char *src) {
  raw_data = src;
}

DigoString::DigoString(const string &src) {
  raw_data = src;
}

DigoString DigoString::operator+(const DigoString& r) {
  return DigoString(this->raw_data + r.raw_data);
}

DigoString DigoString::operator+(const char* r) {
  return DigoString(this->raw_data + r);
}

int64_t DigoString::Compare(const DigoString& r) {
  return strcmp(this->raw_data.c_str(), r.raw_data.c_str());
}

int64_t DigoString::Size() {
  return this->raw_data.length();
}
