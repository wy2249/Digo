
#include "async.h"
#include "master_worker.h"

#include <functional>

using namespace std;

shared_ptr<Async> Async::CreateLocal(string digo_func_name, bytes parameters) {
  shared_ptr<Async> async = make_shared<Async>();
  if (ASYNC_DEBUG) {
      cout << "Local job created: " << async.get() << " func_name: " <<
      digo_func_name << " arg len: " << parameters.length << endl;
  }
  async->result_set_ = false;
  async->std_future_obj_ = std::async([=] {
    return CallFunctionByName(digo_func_name, parameters);
  });
  return async;
}

shared_ptr<Async> Async::CreateRemote(string digo_func_name, bytes parameters) {
  shared_ptr<Async> async = make_shared<Async>();
  async->result_set_ = false;
  async->std_future_obj_ = std::async([=] {
    return Master::GetInst()->CallRemoteFunctionByName(
        digo_func_name, parameters);
  });
  return async;
}

bytes Async::Await() {
  std::lock_guard l(this->lock_);
  if (ASYNC_DEBUG) {
      cout << "Awaiting on job " << this << endl;
  }
  if (result_set_) {
      return result_;
  }
  result_set_ = true;
  result_ = this->std_future_obj_.get();
  return result_;
}
