//
// Created by VM on 2021/3/21.
//

#include "serialization.h"

Serialization::Serialization() {

}

ExtractionResult Serialization::Extract(byte *stream, int len) {
    vector<byte> tmp;
    for (int i = 0; i < len; i++) {
        tmp.push_back(stream[i]);
    }
    return Extract(tmp);
}

ExtractionResult Serialization::Extract(vector<byte> & stream) {
    // extract header to get type info
    ExtractionResult result;
    int iter = 0;
    for ( ; ; ) {
        // 4 bytes header indicating the type
        int type = ExtractInt32NoHeader(stream, &iter);
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
        }
        if (iter == stream.size()) {
            break;
        }
    }
    return result;
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
