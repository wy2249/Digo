/* The Digo Serialization Library.
 * It provides serialization interface for each Digo type.
 * Author:
 * Date: 2021/3/21
 */

#include "serialization.h"

Serialization::Serialization() {

}

void Serialization::Extract(byte *stream, int len) {
    if (stream == nullptr || len == 0) {
        throw EmptyStreamException();
    }
    vector<byte> tmp;
    tmp.reserve(len);
    for (int i = 0; i < len; i++) {
        tmp.push_back(stream[i]);
    }
    Extract(tmp);
}

void Serialization::Extract(vector<byte> & stream) {
    // extract header to get type info
    ExtractionResult result;
    int iter = 0;
    for ( ; ; ) {
        // 4 bytes header indicating the type
        auto type = (digo_type)ExtractInt32NoHeader(stream, &iter);
        switch (type) {
            case TYPE_STR: {
                auto str = (ExtractStringNoHeader(stream, &iter));
                result.extracted_cells.emplace_back(str);
                break;
            }
            case TYPE_INT32: {
                auto num = ExtractInt32NoHeader(stream, &iter);
                result.extracted_cells.emplace_back(num);
                break;
            }
            case TYPE_INT64: {
                auto num = ExtractInt64NoHeader(stream, &iter);
                result.extracted_cells.emplace_back(num);
                break;
            }
            case TYPE_DOUBLE: {
                auto num = ExtractDoubleNoHeader(stream, &iter);
                result.extracted_cells.emplace_back(num);
                break;
            }
            case TYPE_SLICE: {
                auto slice = ExtractSliceNoHeader(stream, &iter);
                result.extracted_cells.emplace_back(std::get<0>(slice), std::get<1>(slice));
                break;
            }
            case TYPE_FUTURE_OBJ:
                throw NotSerializableException("future_obj cannot be serialized");
            case TYPE_UNDEFINED:
                throw NotSerializableException("type undefined");
        }
        if (iter == stream.size()) {
            break;
        }
    }
    this->extraction_result_ = result;
    this->extraction_ptr_ = 0;
}

TypeCell Serialization::ExtractOne() {
    int idx = this->extraction_ptr_;
    int size = this->extraction_result_.extracted_cells.size();
    if (idx >= size) {
        throw ExtractionWrongIndexException(idx, size);
    }
    auto ret = this->extraction_result_.extracted_cells.at(this->extraction_ptr_);
    this->extraction_ptr_++;
    return ret;
}

void Serialization::AddSlice(const vector<TypeCell> && arr, digo_type sliceType) {
    return AddSlice(arr, sliceType);
}

void Serialization::AddSlice(const vector<TypeCell> & arr, digo_type sliceType) {
    AddHeader(TYPE_SLICE);
    AddInt32NoHeader(arr.size());
    AddInt32NoHeader((int32_t)sliceType);
    for (int i = 0; i < arr.size(); i++) {
        digo_type type = arr[i].type;
        auto cell = arr[i];
        switch (type) {
            case TYPE_STR: {
                AddString(cell.str);
                break;
            }
            case TYPE_INT32: {
                AddInt32(cell.num32);
                break;
            }
            case TYPE_INT64: {
                AddInt64(cell.num64);
                break;
            }
            case TYPE_DOUBLE: {
                AddDouble(cell.num_double);
                break;
            }
            case TYPE_SLICE: {
                throw NotSerializableException("are you sure to support nested slice?");
            }
            case TYPE_FUTURE_OBJ:
                throw NotSerializableException("future_obj cannot be serialized");
            case TYPE_UNDEFINED:
                throw NotSerializableException("type undefined");
        }
    }
}

std::tuple<vector<TypeCell>, digo_type> Serialization::ExtractSliceNoHeader(vector<byte> & stream, int *iter) {
    auto size = ExtractInt32NoHeader(stream, iter);
    auto sliceType = static_cast<digo_type>(ExtractInt32NoHeader(stream, iter));
    vector<TypeCell> result;
    for (int32_t i = 0; i < size; i++) {
        auto type = (digo_type)ExtractInt32NoHeader(stream, iter);
        switch (type) {
            case TYPE_STR: {
                auto str = (ExtractStringNoHeader(stream, iter));
                result.emplace_back(str);
                break;
            }
            case TYPE_INT32: {
                auto num = ExtractInt32NoHeader(stream, iter);
                result.emplace_back(num);
                break;
            }
            case TYPE_INT64: {
                auto num = ExtractInt64NoHeader(stream, iter);
                result.emplace_back(num);
                break;
            }
            case TYPE_DOUBLE: {
                auto num = ExtractDoubleNoHeader(stream, iter);
                result.emplace_back(num);
                break;
            }
            case TYPE_SLICE: {
                throw NotSerializableException("are you sure to support nested slice? (ext)");
            }
            case TYPE_FUTURE_OBJ:
                throw NotSerializableException("future_obj cannot be extracted");
            case TYPE_UNDEFINED:
                throw NotSerializableException("type undefined (ext)");
        }
    }
    return std::make_tuple(result, sliceType);
}

void Serialization::AddString(const string & str) {
    AddHeader(TYPE_STR);
    AddInt32NoHeader(str.size());
    for (int i = 0; i < str.size(); i++) {
        AddToEnd({static_cast<byte>(str[i])});
    }
}

string Serialization::ExtractStringNoHeader(vector<byte> & stream, int *iter) {
    int32_t cnt = ExtractInt32NoHeader(stream, iter);
    string ret;
    for (int i = 0; i < cnt; i++) {
        ret += stream.at(*iter);
        (*iter)++;
    }
    return ret;
}

void Serialization::AddInt32(int32_t num) {
    AddHeader(TYPE_INT32);
    AddInt32NoHeader(num);
}

void Serialization::AddInt64(int64_t num) {
    AddHeader(TYPE_INT64);
    AddInt64NoHeader(num);
}

void Serialization::AddDouble(double num) {
    AddHeader(TYPE_DOUBLE);
    byte* ptr = (byte*)(&num);
    for (int i = 0; i < sizeof(double); i++) {
        AddToEnd({ptr[i]});
    }
};

double Serialization::ExtractDoubleNoHeader(vector<byte> & stream, int *iter) {
    double result;
    byte* ptr = (byte*)(&result);
    for (int i = 0; i < sizeof(double); i++) {
        ptr[i] = stream.at((*iter));
        (*iter)++;
    }
    return result;
}

void Serialization::AddHeader(digo_type type) {
    AddInt32NoHeader(type);
    // AddToEnd(PaddingFront({(byte)type}, 2));
}

vector<byte> && Serialization::PaddingFront(vector<byte> && bytes, int length) {
    int n = bytes.size();
    if (n % length != 0) {
        bytes.insert(bytes.begin(), n % length, 0);
    }
    return std::move(bytes);
}

void Serialization::AddToEnd(vector<byte> && in) {
    content_.insert(content_.end(), in.begin(), in.end());
}

void Serialization::AddInt32NoHeader(int32_t num) {
    for (int i = 0; i < 4; i++) {
        AddToEnd({static_cast<byte>((num >> ((3-i) * 8)) & 0xff)});
    }
}

int32_t Serialization::ExtractInt32NoHeader(vector<byte> & stream, int *iter) {
    int32_t num = 0;
    for (int i = 0; i < 4; i++) {
        num = (num << 8) + stream.at((*iter));
        (*iter)++;
    }
    return num;
}

void Serialization::AddInt64NoHeader(int64_t num) {
    for (int i = 0; i < 8; i++) {
        AddToEnd({static_cast<byte>((num >> ((7-i) * 8)) & 0xff)});
    }
}

int64_t Serialization::ExtractInt64NoHeader(vector<byte> & stream, int *iter) {
    int64_t num = 0;
    for (int i = 0; i < 8; i++) {
        num = (num << 8) + stream.at(*iter);
        (*iter)++;
    }
    return num;
}

vector<byte> Serialization::Get() {
    return content_;
}

byte *Serialization::GetBytes() {
    byte* bytes = new byte[content_.size()];
    int i = 0;
    for (byte b : content_) {
        bytes[i++] = b;
    }
    return bytes;
}

int Serialization::GetSize() {
    return content_.size();
}
