/* This file provides common type definition, for the Digo libraries.
 *
 * Author: sh4081
 * Date: 2021/3/21
 */

#ifndef DIGO_LINKER_COMMON_H_
#define DIGO_LINKER_COMMON_H_

#include <string>
#include <memory>
#include <map>
#include <iostream>
#include <utility>
#include <vector>

#include "gc.h"

using std::string;
typedef unsigned char byte;

enum digo_type {
    TYPE_UNDEFINED = 0,
    TYPE_STR = 1,
    TYPE_INT32 = 2,
    TYPE_INT64 = 3,
    TYPE_DOUBLE = 4,
    TYPE_SLICE = 5,
    /*  future object cannot be serialized,
     *  but may be stored in Slice
     */
    TYPE_FUTURE_OBJ = 6,
};

class TypeCell {
public:
    TypeCell() = default;
    explicit TypeCell(string s) : str(std::move(s)), type(TYPE_STR) {}
    explicit TypeCell(int32_t num) : num32(num), type(TYPE_INT32) {}
    explicit TypeCell(int64_t num) : num64(num), type(TYPE_INT64) {}
    explicit TypeCell(double num) : num_double(num), type(TYPE_DOUBLE) {}
    explicit TypeCell(std::vector<TypeCell> a, digo_type t) : arr(std::move(a)), arr_slice_type(t), type(TYPE_SLICE) {}

    digo_type type = TYPE_UNDEFINED;
    int32_t  num32 = 0;
    int64_t  num64 = 0;
    double   num_double = 0.0;
    void*    slice_obj = nullptr;
    /*  use str_obj for a digo string object  */
    void*    str_obj = nullptr;
    void*    future_obj = nullptr;

    /*   serializer reserved  */
    string   str;
    std::vector<TypeCell> arr;
    digo_type arr_slice_type = TYPE_UNDEFINED;
};

namespace Linker {

    class noncopyable {
    protected:
        noncopyable() = default;

        virtual ~noncopyable() = default;

    public:
        noncopyable(const noncopyable &) = delete;

        noncopyable &operator=(const noncopyable &) = delete;
    };

}

#endif //DIGO_LINKER_COMMON_H_
