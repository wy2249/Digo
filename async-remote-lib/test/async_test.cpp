//
// Created by 陈语梵 on 3/8/21.
//

#include "async.h"
#include "master_worker.h"
#include "gtest/gtest.h"

TEST(CreateRemoteTest, Normal) {
  auto mr = Master::GetInst();
  auto wk = Worker::GetInst();
  std::thread([&]{mr->Listen("127.0.0.1:9999");}).detach();
  std::thread([&]{wk->Start("127.0.0.1:9999", "127.0.0.1:9998");}).detach();

  auto params = to_bytes("bar");
  auto f = Async::CreateRemote("foo", params);
  auto result = f->Await();
  auto result_str = to_string(result);
  ASSERT_EQ(result_str, "bar");
}
