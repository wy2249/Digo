//
// Created by 陈语梵 on 3/6/21.
//

#include <map>
#include <async.h>

#include "gtest/gtest.h"
#include "network.h"

// FIXME(yufan): make it a more automatic test
TEST(ServerTest, Normal) {
  auto s = Server::Create("127.0.0.1:9999");
  auto handlers = std::map<string, Handler>{
      {"foo", [=](const string& data){
        std::cout << "foo!" << std::endl;
        return "success\n";
      }}
  };
  s->SetHandlers(handlers);
  auto f = std::async([&]{ s->Start();});
  std::cout << "telnet 127.0.0.1 9999" << std::endl;
  std::cout << "0010foo\n\r\n\rend" << std::endl;
}



