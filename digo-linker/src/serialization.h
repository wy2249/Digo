/* See serialization.cpp for details.
 *
 * Author: sh4081
 * Date: 2021/3/21
 */

#ifndef DIGO_LINKER_SERIALIZATION_H
#define DIGO_LINKER_SERIALIZATION_H

#include "common.h"

#include <utility>
#include <vector>
#include <exception>

using std::exception;
using std::vector;

class ExtractionResult {
public:
    ExtractionResult() = default;
    int err_number = 0;
    string err_info;

    vector<TypeCell> extracted_cells;

};

class Serialization {
public:
    Serialization();
    void Extract(vector<byte> & stream);
    void AddString(const string &);
    void AddInt32(int32_t);
    void AddInt64(int64_t);
    void AddDouble(double);
    void AddSlice(const vector<TypeCell> & arr, digo_type sliceType);
    void AddSlice(const vector<TypeCell> && arr, digo_type sliceType);
    vector<byte> Get();

    void Extract(byte* stream, int len);

    const ExtractionResult& GetResult() {
        return extraction_result_;
    }

    TypeCell ExtractOne();

    byte* GetBytes();
    int GetSize();

protected:
    void AddHeader(digo_type);
    vector<byte> && PaddingFront(vector<byte> &&, int length);
    void AddToEnd(vector<byte> &&);
    void AddInt32NoHeader(int32_t);
    void AddInt64NoHeader(int64_t);
    string ExtractStringNoHeader(vector<byte> &, int *iter);
    int32_t ExtractInt32NoHeader(vector<byte> &, int *iter);
    int64_t ExtractInt64NoHeader(vector<byte> &, int *iter);
    double ExtractDoubleNoHeader(vector<byte> &, int *iter);

    std::tuple<vector<TypeCell>, digo_type> ExtractSliceNoHeader(vector<byte> &, int *iter);

    vector<byte> content_;

    ExtractionResult extraction_result_;

    int extraction_ptr_ = 0;

};

class EmptyStreamException: public exception {
public:
    const char * what() const noexcept override {
        return "empty stream";
    }
};

class ExtractionWrongIndexException: public exception {
public:
    ExtractionWrongIndexException(int i, int len) {
        msg = "Index: ";
        msg += std::to_string(i);
        msg += ", out of bound ";
        msg += std::to_string(len);
    }
    const char * what() const noexcept override {
        return msg.c_str();
    }
private:
    string msg;
};

class NotSerializableException: public exception {
public:
    NotSerializableException(string err) {
        msg = std::move(err);
    }
    const char * what() const noexcept override {
        return msg.c_str();
    }
private:
    string msg;
};

class NullPointerException: public exception {
public:
    NullPointerException(string err) {
        msg = std::move(err);
    }
    const char * what() const noexcept override {
        return msg.c_str();
    }
private:
    string msg;
};

#endif //DIGO_LINKER_SERIALIZATION_H
