//
// Created by VM on 2021/3/25.
//

#ifndef ASYNC_REMOTE_LIB_WRAPPER_H
#define ASYNC_REMOTE_LIB_WRAPPER_H

typedef int32_t int32;

extern "C" {
__attribute__((noinline)) void MasterEntry();
__attribute__((noinline)) void WorkerEntry();
__attribute__((noinline)) void* CreateAsyncJob(int32, byte*, int32);
__attribute__((noinline)) void* CreateRemoteJob(int32, byte*, int32);
__attribute__((noinline)) void AwaitJob(void*, byte**, int32*);

__attribute__((noinline)) void JobIncRef(void*);
__attribute__((noinline)) void JobDecRef(void*);

__attribute__((noinline)) void* CreateString(const char*);
__attribute__((noinline)) void StringIncRef(void*);
__attribute__((noinline)) void StringDecRef(void*);
__attribute__((noinline)) const char* GetString(void*);

// we maintain a name->id map and an id->name map in memory
__attribute__((noinline)) void ASYNC_AddFunction(int32 id, char* func_name);
__attribute__((noinline)) const char* ASYNC_GetFunctionName(int32 id);
__attribute__((noinline)) int32 ASYNC_GetFunctionId(const char* func_name);

__attribute__((noinline)) void Debug_Real_LinkerCallFunction(int32_t id, int32_t arg_len);

}

#endif //ASYNC_REMOTE_LIB_WRAPPER_H
