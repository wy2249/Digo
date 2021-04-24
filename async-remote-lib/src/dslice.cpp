//
// Created by 陈语梵 on 4/8/21.
//

#include "dslice.h"
#include <iterator>
#include <cstdarg>

class TypeCellArray {
public:
    vector<TypeCell> arr_;
    digo_type type_;
    explicit TypeCellArray(digo_type type) {
        type_ = type;
    }
    TypeCellArray(digo_type type, vector<TypeCell> && arr): TypeCellArray(type, arr) {

    }
    TypeCellArray(digo_type type, vector<TypeCell> & arr) {
        type_ = type;
        arr_ = arr;
        switch (type) {
            case TYPE_STR:
                for (auto & tc : arr_) {
                    ((DObject *)tc.str_obj)->IncRef();
                }
                break;
            case TYPE_FUTURE_OBJ:
                for (auto & tc : arr_) {
                    ((DObject *)tc.future_obj)->IncRef();
                }
                break;
            default:
                break;
        }
    }

    vector<TypeCell> * get() {
        return &arr_;
    }

    ~TypeCellArray() {
        switch (type_) {
            case TYPE_STR:
                for (auto & tc : arr_) {
                    ((DObject *)tc.str_obj)->DecRef();
                }
                break;
            case TYPE_FUTURE_OBJ:
                for (auto & tc : arr_) {
                    ((DObject *)tc.future_obj)->DecRef();
                }
                break;
            default:
                break;
        }
    }
};

DigoSlice::DigoSlice(digo_type t) {
    this->raw_data_ = make_shared<TypeCellArray>(t);
    this->type = t;
    this->begin_ = this->end_ = 0;
}

std::tuple<vector<TypeCell> &, size_t &, size_t &> DigoSlice::Data() {
    return std::make_tuple(std::ref(*this->raw_data_->get()),
                           std::ref(this->begin_), std::ref(this->end_));
}

int64_t DigoSlice::Size() const {
    return static_cast<int64_t>(this->end_ - this->begin_);
}

digo_type DigoSlice::Type() const {
    return this->type;
}

TypeCell &DigoSlice::Index(int64_t idx) const {
    return *(this->raw_data_->get()->begin() + this->begin_ + idx);
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

    if (ret->end_ < ret->raw_data_->get()->size()) {
        (*ret->raw_data_->get())[ret->end_] = tv;
    } else {
        ret->raw_data_ = make_shared<TypeCellArray>(this->type,
                vector<TypeCell>(
                        ret->raw_data_->get()->begin() + ret->begin_,
                        ret->raw_data_->get()->begin() + ret->end_));
        ret->raw_data_->get()->push_back(tv);
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

DigoSlice::~DigoSlice() {

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
            ((DObject*)tv.str_obj)->IncRef();
            break;
        case TYPE_FUTURE_OBJ:
            tv.future_obj = va_arg(valist, void*);
            ((DObject*)tv.future_obj)->IncRef();
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
    ((DigoString *)val)->IncRef();
    ((DigoString *)((DigoSlice *) obj)->Index(idx).str_obj)->DecRef();
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
    ((DObject*)tv.future_obj)->IncRef();
    ((DObject *)((DigoSlice *) obj)->Index(idx).future_obj)->DecRef();
    ((DigoSlice *) obj)->Index(idx) = tv;
    return val;
}
