//
// Created by 陈语梵 on 4/4/21.
//

#include "dstring.h"
#include "gtest/gtest.h"

TEST(DigoStringTest, Normal) {
  auto ds = CreateString("foo");
  ASSERT_STREQ(GetCStr(ds), "foo");

  auto ds_2 = AddCString(ds, "foo");
  auto ds_3 = AddString(ds, ds);

  ASSERT_STREQ(GetCStr(ds_2),
      GetCStr(ds_3));

  auto ds_4 = CloneString(ds);
  ASSERT_STREQ(GetCStr(ds_4),
      GetCStr(ds));

  ASSERT_EQ(0, CompareString(ds, ds));
  ASSERT_GT(0, CompareString(ds, ds_2));
  ASSERT_LT(0, CompareString(ds_2, ds));

  ASSERT_EQ(3, GetStringSize(ds));

  auto ds_5 = CreateEmptyString();
  ASSERT_EQ(0, GetStringSize(ds_5));
}

