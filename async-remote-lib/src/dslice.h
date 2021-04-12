#ifndef ASYNC_REMOTE_LIB_SRC_DSLICE_H_
#define ASYNC_REMOTE_LIB_SRC_DSLICE_H_

#include "common.h"
#include "dstring.h"
#include "../../digo-linker/src/common.h"

class DigoSlice {
public:
  DigoSlice(digo_type t);

  std::tuple<vector<TypeCell>&, size_t&, size_t&> Data();

  int64_t Size() const;

  digo_type Type() const;

  DigoSlice Append(const TypeCell &tv);

  DigoSlice Slice(int64_t begin, int64_t end) const;

  TypeCell &Index(int64_t idx) const;

private:
  shared_ptr<vector<TypeCell>> raw_data_;

  digo_type type = TYPE_UNDEFINED;
  size_t begin_, end_;
};

#include "../../digo-linker/src/gc.h"

using DSliObject = DObject<DigoSlice>;

extern "C" {

void* CreateSlice(int64_t type);

void* SliceSlice(void* obj, int64_t begin, int64_t end);

void* CloneSlice(void* obj);

void* SliceAppend(void* obj, ...);

int64_t GetSliceSize(void* obj);


void* GetSliceIndexString(void* obj, int64_t idx);

int64_t* GetSliceIndexInt(void* obj, int64_t idx);

double* GetSliceIndexDouble(void* obj, int64_t idx);

void* GetSliceIndexFuture(void* obj, int64_t idx);
}


#endif //ASYNC_REMOTE_LIB_SRC_RESOURCE_H_
