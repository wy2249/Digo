//
// Created by 陈语梵 on 4/4/21.
//

#include "dstring.h"
#include "gtest/gtest.h"

TEST(DigoStringTest, Normal) {
  auto ds = CreateString("foo");
  ASSERT_STREQ(GetCStr(ds.get()), "foo");

  auto ds_2 = AddCString(ds.get(), "foo");
  auto ds_3 = AddString(ds.get(), ds.get());

  ASSERT_STREQ(GetCStr(ds_2.get()),
      GetCStr(ds_3.get()));

  auto ds_4 = CloneString(ds.get());
  ASSERT_STREQ(GetCStr(ds_4.get()),
      GetCStr(ds.get()));

  ASSERT_EQ(0, CompareString(ds.get(), ds.get()));
  ASSERT_GT(0, CompareString(ds.get(), ds_2.get()));
  ASSERT_LT(0, CompareString(ds_2.get(), ds.get()));

  ASSERT_EQ(3, GetStringSize(ds.get()));

  auto ds_5 = CreateEmptyString();
  ASSERT_EQ(0, GetStringSize(ds_5.get()));
}

