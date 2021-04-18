/* This file exports the GC_DecRef API for reference count GC.
 * The compiler may trace Digo Objects allocated in heap, and releases them
 * using this API,
 * if the objects do not escape their scope.
 *
 * Author:
 * Date: 2021/4/14
 */

#include "gc.h"
#include "builtin_types.h"

using namespace std;

static_assert(sizeof(DObject<void>) == sizeof(DObject<int64_t>));
static_assert(sizeof(DObject<void>) == sizeof(DObject<DigoSlice>));
static_assert(sizeof(DObject<void>) == sizeof(DObject<DigoString>));

/* The memory layout of DObject is same, so
 * we can have a general IncRef/DecRef wrapper.
 *
 * Since there is no `real` async function in our project
 * (all async functions goes through the serialization),
 * IncRef can be omitted.
 */

extern "C" {
    void GC_DecRef(void* obj);
}

void GC_DecRef(void* obj) {
    /*  convert it to any type you want  */
    auto o = (DObject<void>*)obj;
    o->DecRef();
}
