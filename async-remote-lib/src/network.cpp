
#include <sys/socket.h>
#include <sys/types.h>
#include <cstdlib>
#include <cstdio>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <iostream>
#include <algorithm>

#include "network.h"

shared_ptr<Client> Client::Create() {
    shared_ptr<Client> client = std::make_shared<Client>();
    client->socket_ = socket(AF_INET, SOCK_STREAM, 0);
    return client;
}

shared_ptr<Server> Server::Create(const string &server_addr) {
  shared_ptr<Server> server = std::make_shared<Server>();

  auto p = server_addr.find(':');

  if (p == -1) {
    perror("parse addr");
    exit(EXIT_FAILURE);
  }

  string addr = server_addr.substr(0, p);
  string port_str = server_addr.substr(p+1);
  unsigned int port = std::stoul(port_str);

  std::cout << "addr: " << addr << " port: " << port << std::endl;

  struct sockaddr_in address{};
  address.sin_family = AF_INET;
  address.sin_port = htons(port);
  address.sin_addr.s_addr = INADDR_ANY;
//  inet_pton(AF_INET, addr.c_str(), &address.sin_addr);

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

  if (bind(listen_fd, (struct sockaddr *)&address, sizeof(address)) < 0) {
    perror("bind");
    exit(EXIT_FAILURE);
  }

  server->socket_ = listen_fd;
  return server;
}

void Server::SetHandlers(const std::map<string, Handler>& hs) {
  this->handlers = hs;
}

[[noreturn]] void Server::Start() {
    if (listen(this->socket_, 128) < 0) {
        perror("listen");
        exit(EXIT_FAILURE);
    }

    int accept_fd;
    socklen_t addr_len;
    struct sockaddr_in addr_in{};

    while (true) {
        std::cout << " accepting..." << std::endl;
        accept_fd = accept(this->socket_,
            (struct sockaddr *)&addr_in, (socklen_t*)&addr_len);
        if (accept_fd < 0) {
            perror("accept");
            continue;
        }

        // parse addr
        char client_addr_cstr[addr_len];
        inet_ntop(AF_INET, &(addr_in.sin_addr), client_addr_cstr, addr_len);

        string client_addr = client_addr_cstr;
        client_addr += ":" + std::to_string(ntohs(addr_in.sin_port));
      this->HandleConn(accept_fd, client_addr);
        std::async([=]{ this->HandleConn(accept_fd, client_addr);});
    }
}

void Server::HandleConn(int fd, const string& client_addr) {
    /* 4bytes: <packet_length> */

    std::cout << "handling..." << std::endl;

    std::string rpc_name, data;

    int n;
    char buf[1024];
    memset(buf, 0, sizeof(buf));

    // read the first 4 bytes and convert it to the total length
    if ((n = read(fd, buf, 4)) != 4) {
        close(fd);
        return;
    }


  auto packet_length = strtoul(buf, nullptr, 10);
  std::cout << "packet_length: " << packet_length << std::endl;
  auto read_left = packet_length;
    while (data.length() != packet_length &&
        (n = read(fd, buf, std::min(read_left, sizeof(buf)-1))) > 0) {
      read_left -= n;
      data += buf;

    }


    int pos;
    if ((pos = data.find(DELIM)) == -1) {
        std::cerr << "the request format is incorrect" << std::endl;
        close(fd);
        return;
    }

    rpc_name = data.substr(0, pos);
    data = data.substr(pos+sizeof(DELIM)-1);
    string resp = this->handlers[rpc_name](data);
    send(fd, std::to_string(packet_length).c_str(), 4, 0);
    send(fd, rpc_name.c_str(), rpc_name.length(), 0);
    send(fd, DELIM, sizeof(DELIM), 0);
    send(fd, resp.c_str(), resp.length(), 0);
    close(fd);
}