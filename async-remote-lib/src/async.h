
#ifndef ASYNC_REMOTE_LIB_SRC_ASYNC_H_
#define ASYNC_REMOTE_LIB_SRC_ASYNC_H_

#include <thread>
#include <memory>
#include <future>
#include <mutex>

#include "common.h"
#include "linker_common.h"

using std::shared_ptr;
using std::future;

#define ENABLE_ASYNC_DEBUG

#ifdef ENABLE_ASYNC_DEBUG
const bool ASYNC_DEBUG = true;
#else
const bool ASYNC_DEBUG = false;
#endif

class Async : public noncopyable {
 public:
  static shared_ptr<Async> CreateLocal(string digo_func_name, bytes parameters);
  static shared_ptr<Async> CreateRemote(string digo_func_name, bytes parameters);
  bytes Await();
 private:
  std::future<bytes> std_future_obj_;
  bool result_set_;
  bytes result_;
  std::mutex lock_;
};

#endif //ASYNC_REMOTE_LIB_SRC_ASYNC_H_
