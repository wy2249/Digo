//
// Created by VM on 2021/3/25.
//

// This file provides library API - LLVM IR boundaries
// for the Digo compiler.
// This wrapper is for future object(Async) and
// linker-reserved objects only.
// For built-in types, the library
// directly uses gc.h template.

// This wrapper:
// 1. Adds GC wrapper for future object.
// 2. Catches and handles all exceptions from C++.
// 3. Provides an entry for the whole program.

#include "../../async-remote-lib/src/async.h"
#include "../../async-remote-lib/src/master_worker.h"

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

static void WrapperExceptionHandler(const std::string& func, std::exception & e) noexcept {
    std::cerr << "Library Wrapper Error: exception: " << typeid(e).name() << " " << e.what() << " caught in function " << func << std::endl;
    sleep(5);
    exit(1);
}

__attribute__((noinline)) int entry(int argc, char* argv[]) {
    string usage = "usage: --worker MasterIP:MasterPort WorkerIP:WorkerPort\n   or --master ip:port\n";
    try {
        if (argc < 3) {
            std::cerr << "Wrong arguments, " + usage;
            exit(1);
        }
        if (string(argv[1]) == "--master") {
            if (argc != 3) {
                std::cerr << "Wrong master arguments, " + usage;
                exit(1);
            }
            auto master = Master::GetInst();
            /*  master listens for new workers in another thread  */
            std::thread([=]{master->Listen(argv[2]);}).detach();
            /*  here the Entry() returns 1 indicating that
             *  the argument is --master, and
             *  control flow will go to digo_main() defined by Digo Compiler
             */
            return 1;
        } else if (string(argv[1]) == "--worker") {
            if (argc != 4) {
                std::cerr << "Wrong worker arguments, " + usage;
                exit(1);
            }
            auto worker = Worker::GetInst();
            /*  worker has to block here  */
            std::thread([=]{ worker->Start(argv[2], argv[3]);})
            .join();
            return 2;
        } else {
            std::cerr << "--master/--worker expected, " + usage;
            exit(1);
        }
    }
    catch (std::exception & e) {
        WrapperExceptionHandler("Entry", e);
    }
    exit(1);
    /*  unreachable  */
    return 0;
}

__attribute__((noinline)) void* CreateAsyncJob(int32 func, byte* args, int32 arg_len) {
    try {
        auto future_obj = Async::CreateLocal(ASYNC_FUNC_ID2NAME[func],
                  bytes{.content=shared_ptr<byte>(args), .length=arg_len});
        return DObject<Async>::Create(future_obj);
    }
    catch (std::exception & e) {
        WrapperExceptionHandler("CreateAsyncJob", e);
    }
    return nullptr;
}

__attribute__((noinline)) void* CreateRemoteJob(int32 func, byte* args, int32 arg_len) {
    try {
        auto future_obj = Async::CreateRemote(ASYNC_FUNC_ID2NAME[func],
                  bytes{.content=shared_ptr<byte>(args), .length=arg_len});
        return DObject<Async>::Create(future_obj);
    }
    catch (std::exception & e) {
        WrapperExceptionHandler("CreateRemoteJob", e);
    }
    return nullptr;
}

__attribute__((noinline)) void JobIncRef(void* future_obj) {
    try {
        ((DObject<Async>*)future_obj)->IncRef();
    }
    catch (std::exception & e) {
        WrapperExceptionHandler("JobIncRef", e);
    }
}

__attribute__((noinline)) void JobDecRef(void* future_obj) {
    try {
        ((DObject<Async>*)future_obj)->DecRef();
    }
    catch (std::exception & e) {
        WrapperExceptionHandler("JobDecRef", e);
    }
}

__attribute__((noinline)) void AwaitJob(void* future_obj, byte** result, int32* len) {
    try {
        auto r = ((DObject<Async>*)future_obj)->Get()->Await();
        // the result will not be deconstructed because
        // we have a reference in Async->result_
        *result = r.content.get();
        *len = r.length;
    }
    catch (std::exception & e) {
        WrapperExceptionHandler("AwaitJob", e);
    }
}

__attribute__((noinline)) void ASYNC_AddFunction(int32 id, char* func_name) {
    try {
        cerr << "Async function " << id << ": " << func_name << " is added\n";
        ASYNC_FUNC_ID2NAME[id] = string(func_name);
        ASYNC_FUNC_NAME2ID[string(func_name)] = id;
    }
    catch (std::exception & e) {
        WrapperExceptionHandler("ASYNC_AddFunction", e);
    }
}

__attribute__((noinline)) const char* ASYNC_GetFunctionName(int32 id) {
    try {
        return ASYNC_FUNC_ID2NAME[id].c_str();
    }
    catch (std::exception & e) {
        WrapperExceptionHandler("ASYNC_GetFunctionName", e);
    }
    return nullptr;
}

__attribute__((noinline)) int32 ASYNC_GetFunctionId(const char* func_name) {
    try {
        return ASYNC_FUNC_NAME2ID[func_name];
    }
    catch (std::exception & e) {
        WrapperExceptionHandler("ASYNC_GetFunctionId", e);
    }
    return -1;
}

__attribute__((noinline)) void Debug_Real_LinkerCallFunction(int32_t id, int32_t arg_len) {
    cerr << "Digo Linker Info: the digo linker is calling func with id " << id << " and arg len " << arg_len << endl;
}

__attribute__((noinline)) void NoMatchExceptionHandler(int32_t id) {
    cerr << "Digo Linker Error: linker call function, NoMatchException, " + to_string(id) + " not valid\n";
    sleep(5);
    exit(1);
}
