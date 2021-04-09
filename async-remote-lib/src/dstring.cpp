#include <cstring>

#include "dstring.h"

void* CreateString(const char* src) {
  return DObject<DigoString>::Create(new DigoString(src));
}

void* CreateEmptyString() {
    return DObject<DigoString>::Create(new DigoString());
}

void* AddString(DObject<DigoString>* l,
                DObject<DigoString>* r) {
    return DObject<DigoString>::Create(new DigoString(
            l->GetObj() + r->GetObj()
            ));
}

void* AddCString(DObject<DigoString>* l, const char* r) {
    return DObject<DigoString>::Create(new DigoString(
            l->GetObj() + r
            ));
}

void* CloneString(DObject<DigoString>* src) {
    return DObject<DigoString>::Create(new DigoString(
            src->GetObj()
            ));
}

int64_t CompareString(DObject<DigoString>* l,
                      DObject<DigoString>* r) {
    return l->GetPtr()->Compare(r->GetObj());
}

int64_t GetStringSize(DObject<DigoString>* s) {
    return s->GetPtr()->Size();
}

const char* GetCStr(DObject<DigoString>* s) {
    return s->GetPtr()->Data().c_str();
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
