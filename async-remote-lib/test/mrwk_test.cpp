//
// Created by 陈语梵 on 3/8/21.
//

#include <thread>

#include "master_worker.h"
#include "gtest/gtest.h"

TEST(MasterWorkerTest, Normal) {
  auto mr = Master::GetInst();
  auto wk = Worker::GetInst();
  std::thread([&]{mr->Listen("127.0.0.1:9999");}).detach();
  sleep(2);

  std::thread([&]{wk->Start("127.0.0.1:9999", "127.0.0.1:9998");}).detach();
  sleep(2);

  vector<byte> body{0, 0, 'a', 'b'};
  auto result = mr->CallRemoteFunctionByName("1234567", body);

  ASSERT_TRUE(equal(body.begin(), body.end(), result.begin()));


  mr->StopListen();
  wk->Stop();

  std::thread([&]{mr->Listen("127.0.0.1:9999");}).detach();
  sleep(2);
}

TEST(MasterWorkerTest, Reconnect) {
  auto mr = Master::GetInst();
  auto wk = Worker::GetInst();
  std::thread([&]{wk->Start("127.0.0.1:9999", "127.0.0.1:9998");}).detach();

  sleep(5);

  std::thread([&]{mr->Listen("127.0.0.1:9999");}).detach();


  vector<byte> body{0, 0, 'a', 'b'};
  auto result = mr->CallRemoteFunctionByName("1234567", body);

  ASSERT_TRUE(equal(body.begin(), body.end(), result.begin()));


  mr->StopListen();
  wk->Stop();
}
