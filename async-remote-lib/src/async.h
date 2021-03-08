
#ifndef ASYNC_REMOTE_LIB_ASYNC_H
#define ASYNC_REMOTE_LIB_ASYNC_H

#include <thread>
#include <memory>
#include <future>

#include "common.h"
#include "linker_common.h"

using std::shared_ptr;
using std::future;

class Async : public noncopyable {
 public:
  static shared_ptr<Async> CreateLocal(string digo_func_name, bytes parameters);
  static shared_ptr<Async> CreateRemote(string digo_func_name, bytes parameters);
  bytes Await();
 private:
  std::future<bytes> std_future_obj_;
};

#endif //ASYNC_REMOTE_LIB_ASYNC_H
