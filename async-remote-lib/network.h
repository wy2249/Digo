
#ifndef ASYNC_REMOTE_LIB_NETWORK_H
#define ASYNC_REMOTE_LIB_NETWORK_H

#include <sys/socket.h>
#include "common.h"

class Client: public noncopyable  {
public:
    static shared_ptr<Client> Create();
    int Connect(string server_addr);

private:
    int socket_;
};

class Server: public noncopyable  {
public:

};

#endif //ASYNC_REMOTE_LIB_NETWORK_H
