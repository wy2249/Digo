//
// Created by 陈语梵 on 3/8/21.
//

#include <iostream>
#include <unistd.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>

#include "common.h"
#include "network.h"
#include "master_worker.h"
#include "linker_common.h"

shared_ptr<Master> Master::master_ = nullptr;
shared_ptr<Worker> Worker::worker_ = nullptr;

vector<byte> to_vector(const bytes &bs) {
  return vector<byte>(bs.content.get(), bs.content.get()+bs.length);
}

bytes to_bytes(const vector<byte> &data) {
  bytes bs;
  byte *content = new byte[data.size()];
  memcpy(content, data.data(), data.size());
  bs.content = shared_ptr<byte>(content);
  bs.length = data.size();
  return bs;
}

map<string, Handler> master_handlers = {
    {"join", [](const vector<byte> &data) {
      auto master = Master::GetInst();
      master->AddWorker(string(data.begin(), data.end()));
      string ret = "success\n";
      return vector<byte>(ret.begin(), ret.end());
    }}
};

shared_ptr<Master> Master::GetInst() {
  if (master_ == nullptr) {
    master_ = std::make_shared<Master>();
  }
  return master_;
}

void Master::StopListen() {
  this->srv->Stop();
  this->srv = nullptr;
  this->worker_pool.clear();
}

void Worker::Stop() {
  this->srv->Stop();
  this->srv = nullptr;
}

void Master::Listen(const string server_addr) {
  if (this->srv) {
    this->StopListen();
  }
  this->srv = Server::Create(server_addr);
  this->srv->SetHandlers(master_handlers);
  this->srv->Start();
}

void Master::AddWorker(const string &worker_addr) {
  this->worker_pool.insert(worker_addr);
}

vector<byte> Master::CallRemoteFunctionByName(const string &digo_func_name,
                                       const vector<byte> &parameters) {
  do {
    // busy waiting when no workers
    while (!this->worker_pool.size()) {
        sleep(1);
    }

    int idx = rand() % this->worker_pool.size();
    auto it = this->worker_pool.begin();
    advance(it, idx);

    shared_ptr<Client> cli = Client::Create();
    vector<byte> resp;
    vector<byte> req(digo_func_name.begin(), digo_func_name.end());
    req.push_back(':');
    req.insert(req.end(), parameters.begin(), parameters.end());


    if (cli->Call(*it, "call", req, resp) != 0) {
      cerr << "call worker fail" << endl;
      sleep(3);
      continue;
    }
    return resp;
  } while (true);
}

shared_ptr<Worker> Worker::GetInst() {
  if (worker_ == nullptr) {
    worker_ = std::make_shared<Worker>();
  }
  return worker_;
}

map<string, Handler> worker_handlers = {
    {"call", [](const vector<byte> &data) {
      auto worker = Worker::GetInst();

      auto p = string(data.begin(), data.end()).find(':');
      if (p == -1) {
        string ret = "error: request format invalid\n";
        return vector<byte>(ret.begin(), ret.end());
      }

      string digo_func_name, params_str;
      digo_func_name = string(data.begin(), data.begin()+p);
      bytes params = to_bytes(vector<byte>(data.begin()+p+1, data.end()));
      bytes result = CallFunctionByName(digo_func_name, params);
      return to_vector(result);
    }}
};

void Worker::Start(const string &server_addr, const string &client_addr) {
  if (this->srv) {
    this->srv->Stop();
    this->srv = nullptr;
  }
  this->srv = Server::Create(client_addr);
  this->srv->SetHandlers(worker_handlers);
  auto f = std::async([&] { this->srv->Start(); });

  auto cli = Client::Create();

  vector<byte> resp;
  if (cli->Call(server_addr, "join", vector<byte>(client_addr.begin(),
      client_addr.end()), resp) != 0) {
    cerr << "join master fail" << endl;
    exit(EXIT_FAILURE);
  }

  if (string(resp.begin(), resp.end()) != "success\n") {
    cerr << "join master fail. reason: " << string(resp.begin(), resp.end()) << endl;
    exit(EXIT_FAILURE);
  }

  f.wait();
}

