//
// Created by 陈语梵 on 3/8/21.
//

#include <iostream>
#include <unistd.h>
#include <cstdlib>

#include "common.h"
#include "network.h"
#include "master_worker.h"
#include "linker_common.h"

shared_ptr<Master> Master::master_ = nullptr;
shared_ptr<Worker> Worker::worker_ = nullptr;

std::string to_string(const bytes &bs) {
  std::string ret;

  ret.assign(bs.content.get(), bs.content.get() + bs.length);
  return ret;
}

bytes to_bytes(const string &data) {
  bytes bs;
  byte *content = new byte[data.length()];
  memcpy(content, data.c_str(), data.length());
  bs.content = std::shared_ptr<byte>(content);
  bs.length = data.length();
  return bs;
}

std::map<string, Handler> master_handlers = {
    {"join", [](const string &data) {
      auto master = Master::GetInst();
      master->AddWorker(data);
      return "success\n";
    }}
};

shared_ptr<Master> Master::GetInst() {
  if (master_ == nullptr) {
    master_ = std::make_shared<Master>();
  }
  return master_;
}

void Master::Listen(const string &server_addr) {
  if (this->srv)
    this->srv->Stop();
  this->srv = Server::Create(server_addr);
  this->srv->SetHandlers(master_handlers);
  this->srv->Start();
}

void Master::AddWorker(const string &worker_addr) {
  this->worker_pool.insert(worker_addr);
}

bytes Master::CallRemoteFunctionByName(const string &digo_func_name,
                                       const bytes &parameters) {
  do {
    // busy waiting when no workers
    while (!this->worker_pool.size());

    int idx = rand() % this->worker_pool.size();
    auto it = this->worker_pool.begin();
    std::advance(it, idx);

    shared_ptr<Client> cli = Client::Create();
    string resp_str;
    if (cli->Call(*it, "call",
                  digo_func_name + ':' + to_string(parameters),
                  resp_str) != 0) {
      std::cerr << "call worker fail" << std::endl;
      sleep(3);
      continue;
    }
    bytes resp = to_bytes(resp_str);
    return resp;
  } while (true);
}

shared_ptr<Worker> Worker::GetInst() {
  if (worker_ == nullptr) {
    worker_ = std::make_shared<Worker>();
  }
  return worker_;
}

std::map<string, Handler> worker_handlers = {
    {"call", [](const string &data) {
      auto worker = Worker::GetInst();

      auto p = data.find(':');
      // zhen hao wan
      if (p == -1) {
        return string("error: request format invalid");
      }

      std::string digo_func_name, params_str;
      digo_func_name = data.substr(0, p);
      params_str = data.substr(p + 1);
      bytes params = to_bytes(params_str);
      bytes result = CallFunctionByName(digo_func_name, params);
      return to_string(result);
    }}
};

void Worker::Start(const string &server_addr, const string &client_addr) {
  if (this->srv)
    this->srv->Stop();
  this->srv = Server::Create(client_addr);
  this->srv->SetHandlers(worker_handlers);
  auto f = std::async([&] { this->srv->Start(); });

  auto cli = Client::Create();

  string resp;
  if (cli->Call(server_addr, "join", client_addr, resp) != 0) {
    std::cerr << "join master fail" << std::endl;
    exit(EXIT_FAILURE);
  }

  if (resp != "success\n") {
    std::cerr << "join master fail. reason: " << resp << std::endl;
    exit(EXIT_FAILURE);
  }

  f.wait();
}

