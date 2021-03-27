//
// Created by VM on 2021/3/27.
//

#ifndef DIGO_LINKER_BUILTIN_TYPE_WRAPPER_H
#define DIGO_LINKER_BUILTIN_TYPE_WRAPPER_H

extern "C" {
__attribute__((noinline)) void* CreateString(const char*);
__attribute__((noinline)) void StringIncRef(void*);
__attribute__((noinline)) void StringDecRef(void*);
__attribute__((noinline)) const char* GetString(void*);
}

#endif //DIGO_LINKER_BUILTIN_TYPE_WRAPPER_H
