//
// Created by 陈语梵 on 4/8/21.
//

#include "dslice.h"
#include "dstring.h"

DigoSlice::DigoSlice(digo_type t) {
  this->raw_data_ = make_shared<vector<TypeCell>>();
  this->type = t;
  this->begin_ = this->end_ = 0;
}


shared_ptr<vector<TypeCell>> DigoSlice::Data() const {
  return this->raw_data_;
}

int64_t DigoSlice::Size() const {
  return static_cast<int64_t>(this->end_ - this->begin_);
}

digo_type DigoSlice::Type() const {
  return this->type;
}

TypeCell& DigoSlice::Index(int64_t idx) const {
  return *(this->raw_data_->begin() + this->begin_ + idx);
}

DigoSlice DigoSlice::Slice(int64_t begin, int64_t end) const {
  auto sub_slice = DigoSlice(*this);
  sub_slice.begin_ = begin;
  sub_slice.end_ = end;
  return sub_slice;
}

DigoSlice DigoSlice::Append(const TypeCell &tv) {
  if (this->end_ < this->raw_data_->size()) {
    (*this->raw_data_)[this->end_] = tv;
  } else {
    this->raw_data_ = make_shared<vector<TypeCell>>(
        this->raw_data_->begin()+this->begin_, this->raw_data_->begin() + this->end_);
    this->raw_data_->push_back(tv);
  }
  this->end_ += 1;
  return DigoSlice(*this);
}

DSliObject* CreateSlice(int64_t type) {
  return DSliObject::Create(new DigoSlice(digo_type(type)));
}

DSliObject* SliceSlice(DSliObject* obj,
    int64_t begin, int64_t end) {
  return DSliObject::Create(new DigoSlice(
      obj->GetPtr()->Slice(begin, end)
      ));
}

DSliObject* CloneSlice(DSliObject* obj) {
  return DSliObject::Create(new DigoSlice(
      obj->GetObj()
  ));
}

DSliObject* SliceAppend(DSliObject* obj, ...) {
  va_list valist;
  va_start(valist, obj);

  TypeCell tv;
  tv.type = obj->GetPtr()->Type();

  switch (tv.type) {
    case TYPE_INT64:
      tv.num64 = va_arg(valist, int64_t);
      break;
    case TYPE_STR:
      tv.str_obj = va_arg(valist, void*);
      break;
    case TYPE_FUTURE_OBJ:
      tv.future_obj = va_arg(valist, void*);
      break;
    case TYPE_DOUBLE:
      tv.num_double = va_arg(valist, double);
      break;
    default:
      cerr << "Error: type undefined" << endl;
  }
  va_end(valist);
  return DSliObject::Create(new DigoSlice(obj->GetPtr()->Append(tv)));
}

int64_t GetSliceSize(DSliObject* obj) {
  return obj->GetPtr()->Size();
}

DStrObject* GetSliceIndexString(DSliObject* obj, int64_t idx) {
  return static_cast<DStrObject*>(obj->GetPtr()->Index(idx).str_obj);
}

int64_t* GetSliceIndexInt(DSliObject* obj, int64_t idx) {
  return &(obj->GetPtr()->Index(idx).num64);
}

double* GetSliceIndexDouble(DSliObject* obj, int64_t idx) {
  return &(obj->GetPtr()->Index(idx).num_double);
}

void* GetSliceIndexFuture(DSliObject* obj, int64_t idx) {
  return obj->GetPtr()->Index(idx).future_obj;
}




