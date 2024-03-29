/* This file provides async API - LLVM IR boundaries.
 * However, these interfaces are not directly used by Compiler.
 * Instead, the Digo Linker uses these APIs and provides simpler
 * interfaces for the Compiler and Async Library.
 *
 * This file also provides an entry for the whole program.
 *
 * Author: sh4081
 * Date: 2021/3/25
 */

#include "../../async-remote-lib/src/async.h"
#include "../../async-remote-lib/src/master_worker.h"

#include "wrapper.h"
#include "gc.h"
#include "serialization_wrapper.h"

#include <memory>
#include <unordered_map>
#include <string>
#include <utility>
#include <unistd.h>

using std::unordered_map;
using std::string;

class DigoFuture : public DObject {
public:
    explicit DigoFuture(shared_ptr<Async> ptr) : p(std::move(ptr)) {}
    shared_ptr<Async> Get() {
        return p;
    }
    const char* name() override {
        return "Future Object";
    }
private:
    shared_ptr<Async> p;
};

unordered_map<int, string> ASYNC_FUNC_ID2NAME;
unordered_map<string, int> ASYNC_FUNC_NAME2ID;

static void WrapperExceptionHandler(const std::string& func, std::exception & e) noexcept {
    std::cerr << "Library Wrapper Error: exception: " << typeid(e).name() << " " << e.what() << " caught in function " << func << std::endl;
    sleep(5);
    exit(1);
}

struct RuntimeInfo {
    shared_ptr<Master> master;
};

RuntimeInfo g_runtime_info;

__attribute__((noinline)) int entry(int argc, char* argv[]) {
    string usage = "usage: --worker MasterIP:MasterPort WorkerIP:WorkerPort\n   or --master ip:port\n";
    try {
        if (argc < 3) {
            if (argc == 2) {
                if(string(argv[1]) == "--no-master") {
                    return 1;
                }
            }
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
            master->WaitForReady();
            cerr << string("Debug Info: Master ready on ") + argv[2] + "\n";
            g_runtime_info.master = master;
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
            cerr << string("Debug Info: Worker ready on ") + argv[3] + ", master: "
                    + argv[2] + ", my pid: " + to_string(getpid())  + "\n";
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

__attribute__((noinline)) void __DIGO_RUNTIME_OnExit() {
    // if (g_runtime_info.master)
        // g_runtime_info.master->StopListen();
    __GC_DEBUG_COLLECT_LEAK_INFO();
}

__attribute__((noinline)) void* CreateAsyncJob(int32 func, byte* args, int32 arg_len) {
    try {
        auto future_obj = Async::CreateLocal(ASYNC_FUNC_ID2NAME[func],
                  bytes{.content=shared_ptr<byte>(args), .length=arg_len});
        return new DigoFuture(future_obj);
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
        return new DigoFuture(future_obj);
    }
    catch (std::exception & e) {
        WrapperExceptionHandler("CreateRemoteJob", e);
    }
    return nullptr;
}

__attribute__((noinline)) void AwaitJob(void* future_obj, byte** result, int32* len) {
    try {
        if (future_obj == nullptr) {
            throw std::bad_function_call();
        }
        auto r = ((DigoFuture*)future_obj)->Get()->Await();
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
    cerr << "Digo Linker Info: the digo linker is calling func with id " + to_string(id) + " and arg len "
     + to_string(arg_len) + "\n";
}

__attribute__((noinline)) void NoMatchExceptionHandler(int32_t id) {
    cerr << "Digo Linker Error: linker call function, NoMatchException, " + to_string(id) + " not valid\n";
    sleep(5);
    exit(1);
}
