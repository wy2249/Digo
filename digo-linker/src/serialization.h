//
// Created by VM on 2021/3/21.
//

#ifndef DIGO_LINKER_SERIALIZATION_H
#define DIGO_LINKER_SERIALIZATION_H

#include "common.h"

#include <utility>
#include <vector>

using std::vector;

enum digo_type {
    TYPE_UNDEFINED = 0,
    TYPE_STR = 1,
    TYPE_INT32 = 2,
    TYPE_INT64 = 3,
};

class ExtractionResult {
public:
    ExtractionResult() = default;
    int err_number = 0;
    string err_info;

    class cell {
    public:
        cell() = default;
        explicit cell(string s) : str(std::move(s)), type(TYPE_STR) {}
        explicit cell(int32_t num) : num32(num), type(TYPE_INT32) {}
        explicit cell(int64_t num) : num64(num), type(TYPE_INT64) {}
        digo_type type = TYPE_UNDEFINED;
        string   str;
        int32_t  num32 = 0;
        int64_t  num64 = 0;
    };

    vector<cell> extracted_cells;

};

class Serialization: public noncopyable {
public:
    Serialization();
    ExtractionResult Extract(vector<byte> & stream);
    void AddString(const string &);
    void AddInt32(int32_t);
    void AddInt64(int64_t);
    vector<byte> Get();
    // TODO: add more types

private:
    void AddHeader(digo_type);
    vector<byte> && PaddingFront(vector<byte> &&, int length);
    void AddToEnd(vector<byte> &&);
    void AddInt32NoHeader(int32_t);
    void AddInt64NoHeader(int64_t);
    string ExtractStringNoHeader(vector<byte> &, int *iter);
    int32_t ExtractInt32NoHeader(vector<byte> &, int *iter);
    int64_t ExtractInt64NoHeader(vector<byte> &, int *iter);

    vector<byte> content_;

};


#endif //DIGO_LINKER_SERIALIZATION_H
