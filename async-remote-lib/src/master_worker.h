//
// Created by 陈语梵 on 3/4/21.
//

#ifndef ASYNC_REMOTE_LIB_SRC_MASTER_WORKER_H_
#define ASYNC_REMOTE_LIB_SRC_MASTER_WORKER_H_

#include <set>

#include "common.h"
#include "network.h"

vector<byte> to_vector(const bytes &bs);

bytes to_bytes(const vector<byte> &data);

class Master : public noncopyable {
 private:
  static shared_ptr<Master> master_;

 public:
  static shared_ptr<Master> GetInst();

  void Listen(string server_addr);

  void StopListen();

  vector<byte> CallRemoteFunctionByName(const string &digo_func_name, const vector<byte> &parameters);

  void AddWorker(const string &worker_addr);

 private:
  shared_ptr<Server> srv;

  std::set<string> worker_pool;
};

class Worker : public noncopyable {
 private:
  static shared_ptr<Worker> worker_;

 public:
  static shared_ptr<Worker> GetInst();

  void Start(const string &server_addr, const string &client_addr);

  void Stop();

 private:
  shared_ptr<Server> srv;
};

#endif //ASYNC_REMOTE_LIB_SRC_MASTER_WORKER_H_
