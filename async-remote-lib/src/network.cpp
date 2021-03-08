
#include <sys/socket.h>
#include <sys/types.h>
#include <cstdlib>
#include <cstdio>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <iostream>
#include <algorithm>
#include <fcntl.h>
#include <thread>

#include "network.h"

string PackData(const string &rpc_name, const string &data) {
  string resp;
  resp = rpc_name + DELIM + data;
  string resp_length = std::to_string(resp.length());
  resp = std::string(4 - resp_length.length(), '0') + resp_length + resp;
  return resp;
}

int ReadUnpack(int fd, string &rpc_name, string &data) {
  int n;
  char buf[1024];
  memset(buf, 0, sizeof(buf));

  // read the first 4 bytes and convert it to the total length
  if ((n = read(fd, buf, 4)) != 4) {
    return -1;
  }

  auto packet_length = strtoul(buf, nullptr, 10);
  auto read_left = packet_length;
  while (data.length() != packet_length &&
      (n = read(fd, buf, std::min(read_left, sizeof(buf) - 1))) > 0) {
    buf[n] = '\0';
    read_left -= n;
    data += buf;
  }

  if (n < 0) {
    return -1;
  }

  int pos;
  if ((pos = data.find(DELIM)) == -1) {
    std::cerr << "the request format is incorrect" << std::endl;
    return -1;
  }
  rpc_name = data.substr(0, pos);
  data = data.substr(pos + sizeof(DELIM) - 1);
  return 0;
}

int ParseAddr(const string &addr, string &hostname, unsigned short &port) {
  auto p = addr.find(':');

  if (p == -1) {
    return -1;
  }
  hostname = addr.substr(0, p);
  string port_str = addr.substr(p + 1);
  port = std::stoul(port_str);
  return 0;
}

shared_ptr<Client> Client::Create() {
  shared_ptr<Client> client = std::make_shared<Client>();
  client->socket_ = socket(AF_INET, SOCK_STREAM, 0);
  return client;
}

shared_ptr<Server> Server::Create(const string &server_addr) {
  shared_ptr<Server> server = std::make_shared<Server>();

  string hostname;
  unsigned short port;
  if (ParseAddr(server_addr, hostname, port) != 0) {
    std::cerr << "parse address failed" << std::endl;
    exit(-1);
  }

  struct sockaddr_in address{};
  memset(&address, 0, sizeof(sockaddr_in));
  address.sin_family = AF_INET;
  address.sin_port = htons(port);
  address.sin_addr.s_addr = inet_addr(hostname.c_str());

  int listen_fd;

  if ((listen_fd = socket(AF_INET, SOCK_STREAM, 0)) == 0) {
    perror("socket failed");
    exit(EXIT_FAILURE);
  }

  int opt = 1;
  if (setsockopt(listen_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt))) {
    perror("setsockopt");
    exit(EXIT_FAILURE);
  }

  if (bind(listen_fd, (struct sockaddr *) &address, sizeof(address)) < 0) {
    perror("bind");
    exit(EXIT_FAILURE);
  }

  server->socket_ = listen_fd;
  return server;
}

void Server::SetHandlers(const std::map<string, Handler> &hs) {
  this->handlers_ = hs;
}

void Server::Stop() {
  close(this->socket_);
}

void Server::Start() {
  if (listen(this->socket_, 128) < 0) {
    perror("listen");
    exit(EXIT_FAILURE);
  }

  int accept_fd;
  socklen_t addr_len;
  struct sockaddr_in addr_in{};

  while (true) {
    if (fcntl(this->socket_, F_GETFD) == -1 && errno == EBADF) {
      std::cout << "listening stopped. Bye" << std::endl;
      return;
    }

    std::cout << " accepting..." << std::endl;
    accept_fd = accept(this->socket_,
                       (struct sockaddr *) &addr_in, (socklen_t *) &addr_len);
    if (accept_fd < 0) {
      perror("accept");
      continue;
    }

    // parse addr
    char client_addr_cstr[addr_len];
    inet_ntop(AF_INET, &(addr_in.sin_addr), client_addr_cstr, addr_len);

    string client_addr = client_addr_cstr;
    client_addr += ":" + std::to_string(ntohs(addr_in.sin_port));
    std::thread([=] { this->HandleConn(accept_fd, client_addr); }).detach();
  }
}

void Server::HandleConn(int fd, const string &client_addr) {
  /* 4bytes: <packet_length> */

  std::cout << "handling..." << std::endl;

  std::string rpc_name, data;

  if (ReadUnpack(fd, rpc_name, data) != 0) {
    close(fd);
    return;
  }

  string resp = this->handlers_[rpc_name](data);
  resp = PackData(rpc_name, resp);
  send(fd, resp.c_str(), resp.length(), 0);
  close(fd);
}

int Client::Call(const string &server_addr, const string &rpc_name,
                 const string &data, string &resp) {
  string hostname;
  unsigned short port;
  if (ParseAddr(server_addr, hostname, port) != 0) {
    // TODO: better error handling
    std::cerr << "parse server address failed" << std::endl;
    exit(EXIT_FAILURE);
  }

  struct sockaddr_in address{};
  memset(&address, 0, sizeof(address));
  address.sin_port = htons(port);
  address.sin_family = AF_INET;
  address.sin_addr.s_addr = inet_addr(hostname.c_str());

  int fd = socket(AF_INET, SOCK_STREAM, 0);

  if (connect(fd, (struct sockaddr *) &address, sizeof(address)) < 0) {
    perror("connect");
    exit(EXIT_FAILURE);
  }

  string req = PackData(rpc_name, data);
  std::cout << req << std::endl;
  if (send(fd, req.c_str(), req.length(), 0) < 0) {
    perror("send");
    exit(EXIT_FAILURE);
  }

  std::string whatever;
  if (ReadUnpack(fd, whatever, resp) == -1) {
    close(fd);
    return -1;
  }
  close(fd);
  return 0;
}