/* This file exports the GC_DecRef API for reference count GC.
 * The compiler may trace Digo Objects allocated in heap, and releases them
 * using this API, if the objects do not escape their scope.
 *
 * Author: sh4081
 * Date: 2021/4/14
 */

#include "gc.h"
#include "builtin_types.h"
#include <unordered_set>

using namespace std;

/* All Digo Objects are inherited from the base class DObject, so
 * we can have a general IncRef/DecRef wrapper.
 *
 * Since there is no `real` async function in our project
 * (all async functions goes through the serialization),
 * IncRef can be omitted.
 *
 * To simplify the implementation in the codegen (in Digo-Compiler),
 * we provide some helper functions here:
 *
 * 1. void* __GC_CreateTraceMap() to create a tracing map.
 * 2. void  __GC_Trace(void* map, void* obj) to add an object to the tracing map.
 * 3. void  __GC_NoTrace(void* map, void* obj) to remove an object from the tracing map.
 * 4. void  __ReleaseAll(void* map) to release(DecRef) all the objects in the tracing map,
 *                                                   and delete the tracing map itself.
 */

extern "C" {
    void __GC_DecRef(void* obj);
    void* __GC_CreateTraceMap();
    void  __GC_Trace(void* map, void* obj);
    void  __GC_NoTrace(void* map, void* obj);
    void  __GC_ReleaseAll(void* map);
}

void __GC_DecRef(void* obj) {
    if (obj == nullptr) {
        return;
    }
    auto o = (DObject*)obj;
    o->DecRef();
}

struct TraceMap {
    unordered_set<void*> s;
};

void* __GC_CreateTraceMap() {
    return new TraceMap();
}

void  __GC_Trace(void* map, void* obj) {
    auto m = (TraceMap*)map;
    m->s.insert(obj);
}

void  __GC_NoTrace(void* map, void* obj) {
    auto m = (TraceMap*)map;
    m->s.erase(obj);
}

void  __GC_ReleaseAll(void* map) {
    auto m = (TraceMap*)map;
    for (auto obj : m->s) {
        __GC_DecRef(obj);
    }
    delete m;
}
