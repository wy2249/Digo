#include <iostream>
#include <sys/types.h>
#include <sys/socket.h>
#include "async.h"
#include "network.h"

int main() {
  auto digo_func_1 = Async::CreateLocal("digo_func_1", bytes{nullptr, 0});
  digo_func_1->Await();

  std::cout << "Hello, World!" << std::endl;
  int s = socket(AF_INET, SOCK_STREAM, 0);
  int s2 = socket(AF_INET, SOCK_STREAM, 0);

  std::cout << "If you are seeing this, the socket is ready, " << s2 << std::endl;
  int acc = accept(s, nullptr, nullptr);
  return acc;
}
