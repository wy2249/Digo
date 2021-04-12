//
// Created by 陈语梵 on 4/8/21.
//

#include "dslice.h"
#include <iterator>
#include <cstdarg>

DigoSlice::DigoSlice(digo_type t) {
  this->raw_data_ = make_shared<vector<TypeCell>>();
  this->type = t;
  this->begin_ = this->end_ = 0;
}


std::tuple<vector<TypeCell>&, size_t&, size_t&> DigoSlice::Data() {
  return std::make_tuple(std::ref(*this->raw_data_),
                         std::ref(this->begin_), std::ref(this->end_));
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

void* CreateSlice(int64_t type) {
  return DSliObject::Create(new DigoSlice(digo_type(type)));
}

void* SliceSlice(void* obj,
    int64_t begin, int64_t end) {
  return DSliObject::Create(new DigoSlice(
      ((DSliObject*)obj)->GetPtr()->Slice(begin, end)
      ));
}

void* CloneSlice(void* obj) {
  return DSliObject::Create(new DigoSlice(
       ((DSliObject*)obj)->GetObj()
  ));
}

void* SliceAppend(void* vobj, ...) {
  va_list valist;
  va_start(valist, vobj);

  auto obj = (DSliObject*)vobj;
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

int64_t GetSliceSize(void* obj) {
  return ((DSliObject*)obj)->GetPtr()->Size();
}

void* GetSliceIndexString(void* obj, int64_t idx) {
  return ((DSliObject*)obj)->GetPtr()->Index(idx).str_obj;
}

int64_t* GetSliceIndexInt(void* obj, int64_t idx) {
  return &((DSliObject*)obj)->GetPtr()->Index(idx).num64;
}

double* GetSliceIndexDouble(void* obj, int64_t idx) {
  return &((DSliObject*)obj)->GetPtr()->Index(idx).num_double;
}

void* GetSliceIndexFuture(void* obj, int64_t idx) {
  return ((DSliObject*)obj)->GetPtr()->Index(idx).future_obj;
}
