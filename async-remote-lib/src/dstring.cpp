#include <cstring>

#include "dstring.h"

void* CreateString(const char* src) {
  return DObject<DigoString>::Create(new DigoString(src));
}

void* CreateEmptyString() {
    return DObject<DigoString>::Create(new DigoString());
}

void* AddString(void* vl,
                void* vr) {
    auto l = (DObject<DigoString>*) vl;
    auto r = (DObject<DigoString>*) vr;
    return DObject<DigoString>::Create(new DigoString(
            l->GetObj() + r->GetObj()
            ));
}

void* AddCString(void* vl, const char* r) {
    auto l = (DObject<DigoString>*) vl;
    return DObject<DigoString>::Create(new DigoString(
            l->GetObj() + r
            ));
}

void* CloneString(void* vsrc) {
    return DObject<DigoString>::Create(new DigoString(
            ((DObject<DigoString>*)vsrc)->GetObj()
            ));
}

int64_t CompareString(void* vl,
                      void* vr) {
    auto l = (DObject<DigoString>*) vl;
    auto r = (DObject<DigoString>*) vr;
    return l->GetPtr()->Compare(r->GetObj());
}

int64_t GetStringSize(void* vs) {
    auto s = (DObject<DigoString>*) vs;
    return s->GetPtr()->Size();
}

const char* GetCStr(void* vs) {
    auto s = (DObject<DigoString>*) vs;
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
