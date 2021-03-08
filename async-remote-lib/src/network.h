
#ifndef ASYNC_REMOTE_LIB__NETWORK_H_
#define ASYNC_REMOTE_LIB__NETWORK_H_

#include <sys/socket.h>
#include <vector>
#include <functional>
#include <map>
#include <string>
#include <ctime>
#include <future>

#include "common.h"

#define DELIM "\r\n\r\n"

typedef std::function<const string &(const string &)> Handler;

class Client : public noncopyable {
 public:
  static shared_ptr<Client> Create();
  int Call(const string &server_addr,
           const string &rpc_name, const string &data, string &resp);

 private:
  int socket_;
};

class Server : public noncopyable {
 public:
  static shared_ptr<Server> Create(const string &server_addr);

  void SetHandlers(const std::map<string, Handler> &);
  void Stop();
  void Start();

 private:
  void HandleConn(int fd, const string &client_addr);

  std::map<string, Handler> handlers_;
  int socket_;
};

#endif //ASYNC_REMOTE_LIB__NETWORK_H_
