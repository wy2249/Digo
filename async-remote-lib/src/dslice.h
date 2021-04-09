#ifndef ASYNC_REMOTE_LIB_SRC_DSLICE_H_
#define ASYNC_REMOTE_LIB_SRC_DSLICE_H_

#include "common.h"
#include "dstring.h"
#include "../../digo-linker/src/common.h"
#include <memory>
#include <cstdint>
#include <iterator>

class DigoSlice {
 public:
  DigoSlice(digo_type t);

  shared_ptr<vector<TypeCell>> Data() const;

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

DSliObject* CreateSlice(int64_t type);

DSliObject* SliceSlice(DSliObject* obj, int64_t begin, int64_t end);

DSliObject* CloneSlice(DSliObject* obj);

DSliObject* SliceAppend(DSliObject* obj, ...);

int64_t GetSliceSize(DSliObject* obj);

DSliObject* GetSliceIndexSlice(DSliObject* obj, int64_t idx);

DStrObject* GetSliceIndexString(DSliObject* obj, int64_t idx);

int64_t* GetSliceIndexInt(DSliObject* obj, int64_t idx);

double* GetSliceIndexDouble(DSliObject* obj, int64_t idx);

void* GetSliceIndexFuture(DSliObject* obj, int64_t idx);

}


#endif //ASYNC_REMOTE_LIB_SRC_RESOURCE_H_
