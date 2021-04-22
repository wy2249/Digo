/* This file provides print & println built-in Digo functions.
 *
 * Author: sh4081
 * Date: 2021/4/10
 */

#include <string>
#include <sstream>

#include <cstdarg>

#include "builtin_types.h"

namespace Print {
    template<typename T>
    string ToString(T num) {
        return std::to_string(num);
    }
    template<>
    string ToString<DigoString*> (DigoString * obj) {
        string ret = obj->Data();
        return ret;
    }
    template<>
    string ToString<void*> (void * obj) {
        std::ostringstream buf;
        buf << "Object: " << obj;
        return buf.str();
    }
    template<>
    string ToString<DigoSlice*> (DigoSlice * obj) {
        auto [underlying_arr, begin, end] = obj->Data();
        auto sliceType = obj->Type();
        string ret = "[";
        for (auto i = begin; i < end; i++) {
            switch (sliceType) {
                case TYPE_DOUBLE:
                    ret += ToString(underlying_arr[i].num_double);
                    break;
                case TYPE_INT32:
                    ret += ToString(underlying_arr[i].num32);
                    break;
                case TYPE_INT64:
                    ret += ToString(underlying_arr[i].num64);
                    break;
                case TYPE_STR:
                    ret += ToString((DigoString*)(underlying_arr[i].str_obj));
                    break;
                case TYPE_SLICE:
                    ret += "Error: Nested Slice";
                    break;
                case TYPE_UNDEFINED:
                    ret += "Error: Type undefined";
                    break;
                case TYPE_FUTURE_OBJ:
                    ret += ToString(underlying_arr[i].future_obj);
                    break;
            }
            ret += ", ";
        }
        ret.pop_back();
        ret.pop_back();
        ret.push_back(']');
        return ret;
    }


    /*  our printf, %d => int, %s => string(obj), %x => future(obj),
     *  %f => double, %l => slice(obj)
     */
    string ToStringV(const string & format, va_list va) {
        string result;
        for (int i = 0; i < (int)format.size(); i++) {
            if (format[i] != '%') {
                result += format[i];
            } else {
                i++;
                if (i >= (int)format.size()) {
                    result += "Invalid Format";
                    break;
                }
                switch (format[i]) {
                    case '%':
                        result += "%";
                        break;
                    case 'd':
                        result += ToString(va_arg(va, int64_t));
                        break;
                    case 'f':
                        result += ToString(va_arg(va, double));
                        break;
                    case 'x':
                        result += ToString(va_arg(va, void*));
                        break;
                    case 's':
                        result += ToString(va_arg(va, DigoString*));
                        break;
                    case 'l':
                        result += ToString(va_arg(va, DigoSlice*));
                        break;
                    default:
                        result += "Invalid Format";
                        break;
                }
            }
        }
        return result;
    }
}

extern "C" {
    /*  we only have two exported functions: print & println   */
    void print(void * format, ...);
    void println(void * format, ...);
}

void print(void * format, ...) {
    auto raw_format = GetCStr(format);
    va_list va;
    va_start(va, format);
    string str = Print::ToStringV(raw_format, va);
    va_end(va);
    cout << str;
}

void println(void * format, ...) {
    auto raw_format = GetCStr(format);
    va_list va;
    va_start(va, format);
    string str = Print::ToStringV(raw_format, va) + "\n";
    va_end(va);
    cout << str;
}
