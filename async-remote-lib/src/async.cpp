
#include "async.h"

#include <functional>

using namespace std;

shared_ptr<Async> Async::CreateLocal(string digo_func_name, bytes parameters) {
  shared_ptr<Async> async = make_shared<Async>();
  async->std_future_obj_ = std::async([=] {
    return CallFunctionByName(digo_func_name, parameters);
  });
  return async;
}

shared_ptr<Async> Async::CreateRemote(string digo_func_name, bytes parameters) {
  shared_ptr<Async> async = make_shared<Async>();
  async->std_future_obj_ = std::async([=] {
    // TODO 1: pick a worker

    // TODO 2: wrap the
    return CallFunctionByName(digo_func_name, parameters);
  });
  return async;
}

bytes Async::Await() {
  return this->std_future_obj_.get();
}
