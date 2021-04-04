#include <iostream>
#include <sys/socket.h>
#include <cstdlib>
#include <cstdio>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <fcntl.h>
#include <thread>
#include <string>
#include <cstring>
#include <cmath>
#include <vector>

#include "network.h"


vector<byte> PackData(const string &rpc_name, const vector<byte> &data) {
  string prefix = rpc_name + DELIM;
  string p_length = to_string(prefix.length() + data.size());
  p_length = string(10 - p_length.length(), '0') + p_length;

  vector<byte> ret;
  ret.insert(ret.end(), p_length.begin(), p_length.end());
  ret.insert(ret.end(), prefix.begin(), prefix.end());
  ret.insert(ret.end(), data.begin(), data.end());
  return ret;
}

int ReadUnpack(int fd, string &rpc_name, vector<byte> &data) {
  int n;
  char buf[1024];
  memset(buf, 0, sizeof(buf));
  data.clear();

  // read the first 10 bytes and convert it to the total length
  if ((n = read(fd, buf, HEADER_LENGTH_SIZE)) != HEADER_LENGTH_SIZE) {
    return -1;
  }

  auto packet_length = strtoul(buf, nullptr, 10);
  size_t read_left = packet_length;
  while (data.size() != packet_length && read_left > 0 &&
      (n = read(fd, buf, std::min(read_left, sizeof(buf)))) > 0) {
    data.insert(data.end(), buf, buf+n);
    read_left -= n;
  }

  if (n < 0) {
    return -1;
  }

  int pos = string(data.begin(), data.end()).find(DELIM);
  if (pos == -1) {
    cerr << "the request format is incorrect" << endl;
    return -1;
  }
  rpc_name = string(data.begin(), data.begin()+pos);
  data = vector<byte>(data.begin()+pos+sizeof(DELIM)-1, data.end());
  return 0;
}

int ParseAddr(const string &addr, string &hostname, unsigned short &port) {
  auto p = addr.find(':');

  if (p == -1) {
    return -1;
  }
  hostname = addr.substr(0, p);
  string port_str = addr.substr(p + 1);
  port = stoul(port_str);
  return 0;
}

shared_ptr<Client> Client::Create() {
  shared_ptr<Client> client = make_shared<Client>();
  client->socket_ = socket(AF_INET, SOCK_STREAM, 0);
  return client;
}

int Client::Call(const string &server_addr, const string &rpc_name,
                 const vector<byte> &data, vector<byte> &resp) {
  string hostname;
  unsigned short port;
  if (ParseAddr(server_addr, hostname, port) != 0) {
    // TODO: better error handling
    cerr << "parse server address failed" << endl;
    exit(EXIT_FAILURE);
  }

  struct sockaddr_in address{};
  memset(&address, 0, sizeof(address));
  address.sin_port = htons(port);
  address.sin_family = AF_INET;
  address.sin_addr.s_addr = inet_addr(hostname.c_str());

  if (connect(this->socket_, (struct sockaddr *) &address, sizeof(address)) < 0) {
    perror("connect");
    exit(EXIT_FAILURE);
  }

  vector<byte> req = PackData(rpc_name, data);
  if (send(this->socket_, req.data(), req.size(), 0) < 0) {
    perror("send");
    exit(EXIT_FAILURE);
  }

  string whatever;
  if (ReadUnpack(this->socket_, whatever, resp) == -1) {
    close(this->socket_);
    return -1;
  }
  close(this->socket_);
  return 0;
}

shared_ptr<Server> Server::Create(const string &server_addr) {
  shared_ptr<Server> server = make_shared<Server>();

  string hostname;
  unsigned short port;
  if (ParseAddr(server_addr, hostname, port) != 0) {
    cerr << "parse address failed" << endl;
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

void Server::SetHandlers(const map<string, Handler> &hs) {
  this->handlers_ = hs;
}

void Server::Stop() {
  close(this->socket_);
}

void Server::Start() {
  if (listen(this->socket_, 128) < 0) {
    perror("server::start::listen");
    exit(EXIT_FAILURE);
  }

  int accept_fd;
  socklen_t addr_len;
  struct sockaddr_in addr_in{};

  while (true) {
    if (fcntl(this->socket_, F_GETFD) == -1 && errno == EBADF) {
      cout << "listening stopped. Bye" << endl;
      return;
    }

    cout << " accepting..." << endl;
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
    client_addr += ":" + to_string(ntohs(addr_in.sin_port));
    std::thread([=] { this->HandleConn(accept_fd, client_addr); }).detach();
  }
}

void Server::HandleConn(int fd, const string &client_addr) {
  /* 4bytes: <packet_length> */

  string rpc_name;
  vector<byte> data;

  if (ReadUnpack(fd, rpc_name, data) != 0) {
    close(fd);
    return;
  }

  vector<byte> resp = this->handlers_[rpc_name](data);
  resp = PackData(rpc_name, resp);
  send(fd, resp.data(), resp.size(), 0);
  close(fd);

}

