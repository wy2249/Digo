//
// Created by 陈语梵 on 3/6/21.
//

#include <map>
#include <thread>
#include <netinet/in.h>
#include <arpa/inet.h>

#include "gtest/gtest.h"
#include "network.h"

TEST(ServerTest, Normal) {
  auto s = Server::Create("127.0.0.1:9999");
  auto handlers = std::map<string, Handler>{
      {"foo", [=](const string &data) {
        return "success\n";
      }}
  };
  s->SetHandlers(handlers);
  std::thread([&] { s->Start(); }).detach();

  auto c = socket(AF_INET, SOCK_STREAM, 0);
  struct sockaddr_in server_addr;
  memset(&server_addr, 0, sizeof(server_addr));
  server_addr.sin_port = htons(9999);
  server_addr.sin_addr.s_addr = inet_addr("127.0.0.1");
  server_addr.sin_family = AF_INET;
  auto r = connect(c, (struct sockaddr *) &server_addr, sizeof(server_addr));
  ASSERT_GE(r, 0);
  constexpr const char kData[] = "0010foo" DELIM "end";
  send(c, kData, sizeof(kData), 0);
  char buf[1024];
  memset(buf, 0, sizeof(buf));
  while (recv(c, buf, sizeof(buf) - 1, 0) > 0);
  ASSERT_STREQ("0015foo" DELIM "success\n", buf);
  s->Stop();
}

TEST(ClientTest, Normal) {
  auto c = Client::Create();
  string resp;

  // FIXME: ncat doesn't exit after test is done
  auto t = std::thread(system, "ncat -l 9999 -k -c 'xargs -n1 echo'");
  sleep(3);

  int r = c->Call("127.0.0.1:9999",
                  "foo", "bar\n", resp);
  ASSERT_EQ(r, 0);
  ASSERT_STREQ("bar\n", resp.c_str());
}



