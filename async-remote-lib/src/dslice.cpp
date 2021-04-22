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

std::tuple<vector<TypeCell> &, size_t &, size_t &> DigoSlice::Data() {
    return std::make_tuple(std::ref(*this->raw_data_),
                           std::ref(this->begin_), std::ref(this->end_));
}

int64_t DigoSlice::Size() const {
    return static_cast<int64_t>(this->end_ - this->begin_);
}

digo_type DigoSlice::Type() const {
    return this->type;
}

TypeCell &DigoSlice::Index(int64_t idx) const {
    return *(this->raw_data_->begin() + this->begin_ + idx);
}

DigoSlice *DigoSlice::Slice(int64_t begin, int64_t end) const {
    auto sub_slice = new DigoSlice(this->type);
    sub_slice->begin_ = begin;
    sub_slice->end_ = end;
    sub_slice->raw_data_ = this->raw_data_;
    return sub_slice;
}

DigoSlice *DigoSlice::Append(const TypeCell &tv) const {
    auto ret = new DigoSlice(this->type);
    ret->begin_ = this->begin_;
    ret->end_ = this->end_;
    ret->raw_data_ = this->raw_data_;

    if (ret->end_ < ret->raw_data_->size()) {
        (*ret->raw_data_)[ret->end_] = tv;
    } else {
        ret->raw_data_ = make_shared<vector<TypeCell>>(
                ret->raw_data_->begin() + ret->begin_, ret->raw_data_->begin() + ret->end_);
        ret->raw_data_->push_back(tv);
    }
    ret->end_ += 1;
    return ret;
}

DigoSlice *DigoSlice::Clone() const {
    auto ret = new DigoSlice(this->type);
    ret->begin_ = this->begin_;
    ret->end_ = this->end_;
    ret->raw_data_ = this->raw_data_;
    return ret;
}

void *CreateSlice(int64_t type) {
    return new DigoSlice(digo_type(type));
}

void *SliceSlice(void *obj,
                 int64_t begin, int64_t end) {
    return ((DigoSlice *) obj)->Slice(begin, end);
}

void *CloneSlice(void *obj) {
    return ((DigoSlice *) obj)->Clone();
}

void *SliceAppend(void *vobj, ...) {
    va_list valist;
    va_start(valist, vobj);

    auto obj = (DigoSlice *) vobj;
    TypeCell tv;
    tv.type = obj->Type();

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
    return obj->Append(tv);
}

int64_t GetSliceSize(void *obj) {
    return ((DigoSlice *) obj)->Size();
}

void *GetSliceIndexString(void *obj, int64_t idx) {
    return ((DigoSlice *) obj)->Index(idx).str_obj;
}

int64_t GetSliceIndexInt(void *obj, int64_t idx) {
    return ((DigoSlice *) obj)->Index(idx).num64;
}

double GetSliceIndexDouble(void *obj, int64_t idx) {
    return ((DigoSlice *) obj)->Index(idx).num_double;
}

void *GetSliceIndexFuture(void *obj, int64_t idx) {
    return ((DigoSlice *) obj)->Index(idx).future_obj;
}

void *SetSliceIndexString(void *obj, int64_t idx, void *val) {
    TypeCell tv;
    tv.type = TYPE_STR;
    tv.str_obj = val;
    ((DigoSlice *) obj)->Index(idx) = tv;
    return val;
}

int64_t SetSliceIndexInt(void *obj, int64_t idx, int64_t val) {
    TypeCell tv;
    tv.type = TYPE_INT64;
    tv.num64 = val;
    ((DigoSlice *) obj)->Index(idx) = tv;
    return val;
}

double SetSliceIndexDouble(void *obj, int64_t idx, double val) {
    TypeCell tv;
    tv.type = TYPE_DOUBLE;
    tv.num_double = val;
    ((DigoSlice *) obj)->Index(idx) = tv;
    return val;
}

void *SetSliceIndexFuture(void *obj, int64_t idx, void *val) {
    TypeCell tv;
    tv.type = TYPE_FUTURE_OBJ;
    tv.future_obj = val;
    ((DigoSlice *) obj)->Index(idx) = tv;
    return val;
}
