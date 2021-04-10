//
// Created by VM on 2021/3/21.
//

#ifndef DIGO_LINKER_SERIALIZATION_H
#define DIGO_LINKER_SERIALIZATION_H

#include "common.h"

#include <utility>
#include <vector>

using std::vector;

class ExtractionResult {
public:
    ExtractionResult() = default;
    int err_number = 0;
    string err_info;

    vector<TypeCell> extracted_cells;

};

class Serialization: public Linker::noncopyable {
public:
    Serialization();
    void Extract(vector<byte> & stream);
    void AddString(const string &);
    void AddInt32(int32_t);
    void AddInt64(int64_t);
    vector<byte> Get();

    void Extract(byte* stream, int len);

    const ExtractionResult& GetResult() {
        return extraction_result_;
    }

    TypeCell ExtractOne();

    byte* GetBytes();
    int GetSize();
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

    ExtractionResult extraction_result_;

    int extraction_ptr_;

};


#endif //DIGO_LINKER_SERIALIZATION_H
