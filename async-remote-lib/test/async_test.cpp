//
// Created by 陈语梵 on 3/8/21.
//

#include "async.h"
#include "master_worker.h"
#include "gtest/gtest.h"

TEST(CreateLocalTest, Normal) {
  auto params = to_bytes({'b', 'a', 'r'});

  auto f = Async::CreateLocal("foo", params);
  auto result = f->Await();

  ASSERT_EQ(result.length, 3);
  for (int i = 0; i < 3; ++i) {
    ASSERT_EQ(*result.content.get()+i, *params.content.get()+i);
  }
}

TEST(CreateRemoteTest, Normal) {
  auto mr = Master::GetInst();
  auto wk = Worker::GetInst();
  std::thread([=]{mr->Listen("127.0.0.1:9999");}).detach();
  sleep(2);

  std::thread([=]{wk->Start("127.0.0.1:9999", "127.0.0.1:9998");}).detach();
  sleep(2);

  auto params = to_bytes({'b', 'a', 'r'});
  auto f = Async::CreateRemote("foo", params);
  auto result = f->Await();
  ASSERT_EQ(result.length, 3);
  for (int i = 0; i < 3; ++i) {
    ASSERT_EQ(*result.content.get()+i, *params.content.get()+i);
  }
  mr->StopListen();
  wk->Stop();
}

TEST(CreateRemoteTest2, Issue19) {
  // no real entry
  // main.cpp is not compiled in Makefile
  auto master = Master::GetInst();
  /*  master listens for new workers in another thread  */
  std::thread([=]{master->Listen("127.0.0.1:20001");}).detach();

  sleep(2);

  int arg_len = 1000;

  byte * args = static_cast<byte *>(malloc(arg_len * sizeof(byte)));
  for (int i = 0; i < arg_len; i++) {
    args[i] = 0;
  }

  bytes bs{
    .content=shared_ptr<byte>(args),
    .length=arg_len
  };

  auto future_obj = Async::CreateRemote("1234567", bs);

  auto worker = Worker::GetInst();

  std::thread([=]{ worker->Start("127.0.0.1:20001", "127.0.0.1:20002");})
      .detach() ;

  cout << "reproduce: awaiting on future object\n";

  auto result = future_obj->Await();

  cout << "reproduce: awaiting on future object end\n";

  for (int i = 0; i < arg_len; ++i) {
    ASSERT_EQ(*(args+i), *(result.content.get()+i));
  }
  master->StopListen();
  worker->Stop();
}
