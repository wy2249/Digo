//
// Created by 陈语梵 on 4/9/21.
//

#include "dslice.h"
#include "gtest/gtest.h"

TEST(DigoSliceTest, Normal) {
  auto sli_1 = CreateSlice(TYPE_INT64);
  ASSERT_EQ(0, GetSliceSize(sli_1));
  sli_1 = SliceAppend(sli_1, 10);
  ASSERT_EQ(1, GetSliceSize(sli_1));
  ASSERT_EQ(10, GetSliceIndexInt(sli_1, 0));

  auto sli_2 = CloneSlice(sli_1);
  ASSERT_NE(sli_1, sli_2);
  ASSERT_EQ(10, GetSliceIndexInt(sli_2, 0));

  for (int i = 0; i < 100; ++i) {
    sli_2 = SliceAppend(sli_2, i);
  }

  ASSERT_EQ(1, GetSliceSize(sli_1));
  ASSERT_EQ(101, GetSliceSize(sli_2));

  auto sli_3 = SliceSlice(sli_2, 10, 20);
  GetSliceIndexInt(sli_3, 0) = 200;
  ASSERT_EQ(200, GetSliceIndexInt(sli_3, 0));
  ASSERT_EQ(200, GetSliceIndexInt(sli_2, 10));

  for (int i = 0; i < 30; ++i)
    SliceAppend(sli_3, 200);

  ASSERT_EQ(200, GetSliceIndexInt(sli_2, 20));
}

