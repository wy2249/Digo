//
// Created by 陈语梵 on 4/12/21.
//

#include <iostream>
#include <string>
#include <fstream>

#include "ioutil.h"
#include "dslice.h"
#include "dstring.h"
#include "gtest/gtest.h"

using std::stringstream;
using std::ofstream;

TEST(ReadStreamTest, Normal) {
  stringstream ss;
  ss << "hello world foo\nhehe,";
  auto sli = ReadStream(ss);

  string exps[] = {"hello", "world", "foo", "hehe,"};
  ASSERT_EQ(4, GetSliceSize(sli));
  for (int i = 0; i < GetSliceSize(sli); ++i) {
    auto dstr = GetSliceIndexString(sli, i);
    ASSERT_EQ(exps[i], GetCStr(dstr));
  }
}

TEST(ReadFileTest, Normal) {
  ofstream f("/tmp/test.txt");
  f << "hello world\n foo hehe,\n";
  f.close();

  auto path = DigoString("/tmp/test.txt");
  auto sli = ReadFile(&path);
  string exps[] = {"hello", "world", "foo", "hehe,"};
  ASSERT_EQ(4, GetSliceSize(sli));
  for (int i = 0; i < GetSliceSize(sli); ++i) {
    auto dstr = GetSliceIndexString(sli, i);
    ASSERT_EQ(exps[i], GetCStr(dstr));
  }
}
