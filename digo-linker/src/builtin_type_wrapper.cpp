//
// Created by VM on 2021/3/27.
//
#include "gc.h"

#include <memory>
#include <unordered_map>
#include <string>
#include <unistd.h>
#include "builtin_type_wrapper.h"

using std::unordered_map;
using std::string;

__attribute__((noinline)) void* CreateString(const char* s) {
    auto str = std::make_shared<string>(s);
    return GC_Create(str);
}

__attribute__((noinline)) void StringIncRef(void* s) {
    GC_IncRef((ref_wrapper<string>*)(s));
}

__attribute__((noinline)) void StringDecRef(void* s) {
    GC_DecRef((ref_wrapper<string>*)(s));
}

__attribute__((noinline)) const char* GetString(void* s) {
    auto r = (ref_wrapper<string>*)(s);
    return r->any_data->c_str();
}

