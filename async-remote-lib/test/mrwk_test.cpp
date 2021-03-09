//
// Created by 陈语梵 on 3/8/21.
//

#include <thread>

#include "master_worker.h"
#include "gtest/gtest.h"

TEST(ByteToString, Normal) {
  bytes bs = {
      .content = nullptr,
      .length = 3,
  };
  byte *bb = new byte[3]{'f', 'o', 'o'};
  bs.content = shared_ptr<byte[]>(bb);
  string expect = "foo";
  string out = to_string(bs);
  ASSERT_EQ(expect, out);
}

TEST(StringToByte, Normal) {
  auto bytes = to_bytes("foo");
  ASSERT_EQ(3, bytes.length);
  ASSERT_EQ('f', bytes.content.get()[0]);
  ASSERT_EQ('o', bytes.content.get()[1]);
  ASSERT_EQ('o', bytes.content.get()[2]);
}

TEST(MasterWorkerTest, Normal) {
  auto mr = Master::GetInst();
  auto wk = Worker::GetInst();
  std::thread([&]{mr->Listen("127.0.0.1:9999");}).detach();
  sleep(2);

  std::thread([&]{wk->Start("127.0.0.1:9999", "127.0.0.1:9998");}).detach();
  sleep(2);

  auto params = to_bytes("bar");
  auto result = mr->CallRemoteFunctionByName("foo", params);
  auto result_str = to_string(result);
  ASSERT_EQ(result_str, "bar");

  mr->StopListen();
  wk->Stop();
}

