
#include "network.h"

using namespace std;

shared_ptr<Client> Client::Create() {
    shared_ptr<Client> client = make_shared<Client>();
    client->socket_ = socket(AF_INET, SOCK_STREAM, 0);
    return client;
}

int Client::Connect(string server_addr) {
    // not implemented
    this->socket_;
    return 0;
}
