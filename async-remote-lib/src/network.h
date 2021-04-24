
#ifndef ASYNC_REMOTE_LIB_SRC_NETWORK_H_
#define ASYNC_REMOTE_LIB_SRC_NETWORK_H_

#include <sys/socket.h>
#include <vector>
#include <functional>
#include <map>
#include <string>
#include <ctime>
#include <future>
#include <atomic>

#include "common.h"


#define DELIM "\r\n\r\n"
#define HEADER_LENGTH_SIZE 10

typedef std::function<vector<byte> (const vector<byte> &)> Handler;

class Client : public noncopyable {
 public:
  static shared_ptr<Client> Create();
  int Call(const string &server_addr,
           const string &rpc_name, const vector<byte> &data, vector<byte> &resp);

 private:
  int socket_;
};

class Server : public noncopyable {
 public:
  static shared_ptr<Server> Create(const string &server_addr);

  void SetHandlers(const std::map<string, Handler> &);
  void Stop();
  void Start();

  ~Server() {this->Stop();}

  bool IsListening();

 private:
  void HandleConn(int fd, const string &client_addr);

  std::map<string, Handler> handlers_;
  int socket_;
  std::atomic<bool> listening_;
};

#endif //ASYNC_REMOTE_LIB_SRC_NETWORK_H_
