#ifndef ASYNC_REMOTE_LIB_SRC_DSLICE_H_
#define ASYNC_REMOTE_LIB_SRC_DSLICE_H_

#include "common.h"
#include "dstring.h"
#include "../../digo-linker/src/common.h"

class TypeCellArray;

class DigoSlice : public DObject {
public:
    explicit DigoSlice(digo_type t);

    ~DigoSlice() override;

    std::tuple<vector<TypeCell> &, size_t &, size_t &> Data();

    [[nodiscard]] int64_t Size() const;

    [[nodiscard]] digo_type Type() const;

    [[nodiscard]] DigoSlice *Append(const TypeCell &tv) const;

    [[nodiscard]] DigoSlice *Slice(int64_t begin, int64_t end) const;

    [[nodiscard]] DigoSlice *Clone() const;

    [[nodiscard]] TypeCell &Index(int64_t idx) const;

    const char *name() override {
        return "Slice Object";
    }

private:
    shared_ptr<TypeCellArray> raw_data_;

    digo_type type = TYPE_UNDEFINED;
    size_t begin_, end_;

};

#include "../../digo-linker/src/gc.h"

extern "C" {

void *CreateSlice(int64_t type);
void *SliceSlice(void *obj, int64_t begin, int64_t end);
void *CloneSlice(void *obj);
void *SliceAppend(void *obj, ...);
int64_t GetSliceSize(void *obj);

void *GetSliceIndexString(void *obj, int64_t idx);
int64_t GetSliceIndexInt(void *obj, int64_t idx);
double GetSliceIndexDouble(void *obj, int64_t idx);
void *GetSliceIndexFuture(void *obj, int64_t idx);

void *SetSliceIndexString(void *obj, int64_t idx, void *val);
int64_t SetSliceIndexInt(void *obj, int64_t idx, int64_t val);
double SetSliceIndexDouble(void *obj, int64_t idx, double val);
void *SetSliceIndexFuture(void *obj, int64_t idx, void *val);
}


#endif //ASYNC_REMOTE_LIB_SRC_RESOURCE_H_
