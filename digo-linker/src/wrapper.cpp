//
// Created by VM on 2021/3/25.
//

#include "../../async-remote-lib/src/async.h"
#include "wrapper.h"
#include "gc.h"
#include "serialization_wrapper.h"

#include <memory>
#include <unordered_map>
#include <string>
#include <unistd.h>

using std::unordered_map;
using std::string;

unordered_map<int, string> ASYNC_FUNC_ID2NAME;
unordered_map<string, int> ASYNC_FUNC_NAME2ID;

__attribute__((noinline)) void MasterEntry() {

}

__attribute__((noinline)) void WorkerEntry() {

}

__attribute__((noinline)) void* CreateAsyncJob(int32 func, byte* args, int32 arg_len) {
    auto future_obj = Async::CreateLocal(ASYNC_FUNC_ID2NAME[func],
                                         bytes{
        .content=shared_ptr<byte>(args), .length=arg_len});
    return GC_Create(future_obj);
}

__attribute__((noinline)) void* CreateRemoteJob(int32 func, byte* args, int32 arg_len) {
    auto future_obj = Async::CreateRemote(ASYNC_FUNC_ID2NAME[func],
                                          bytes{
        .content=shared_ptr<byte>(args), .length=arg_len});
    return GC_Create(future_obj);
}

__attribute__((noinline)) void JobIncRef(void* future_obj) {
    GC_IncRef((ref_wrapper<Async>*)(future_obj));
}

__attribute__((noinline)) void JobDecRef(void* future_obj) {
    GC_DecRef((ref_wrapper<Async>*)(future_obj));
}

__attribute__((noinline)) void AwaitJob(void* future_obj, byte** result, int32* len) {
    auto r =  ((ref_wrapper<Async>*)future_obj)->any_data->Await();
    // the result will not be deconstructed because
    // we have a reference in Async->result_
    *result = r.content.get();
    *len = r.length;
}

__attribute__((noinline)) void ASYNC_AddFunction(int32 id, char* func_name) {
    ASYNC_FUNC_ID2NAME[id] = string(func_name);
    ASYNC_FUNC_NAME2ID[string(func_name)] = id;
}

__attribute__((noinline)) const char* ASYNC_GetFunctionName(int32 id) {
    return ASYNC_FUNC_ID2NAME[id].c_str();
}

__attribute__((noinline)) int32 ASYNC_GetFunctionId(const char* func_name) {
    return ASYNC_FUNC_NAME2ID[func_name];
}

__attribute__((noinline)) void Debug_Real_LinkerCallFunction(int32_t id, int32_t arg_len) {
    cout << "If you are seeing this, the digo linker is ready and is calling func with id " << id << " and arg len " << arg_len << endl;
}

__attribute__((noinline)) void NoMatchExceptionHandler(int32_t id) {
    cout << "Digo linker call function, exception, " + to_string(id) + " not valid\n";
    sleep(5);
    exit(1);
}
