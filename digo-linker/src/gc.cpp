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
#include <unordered_map>

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

void __GC_DecRef(void* obj) {
    if (obj == nullptr) {
        return;
    }
    auto o = (DObject*)obj;
    o->DecRef();
}

struct TraceMap {
    unordered_set<void*> s;
    unordered_map<void*, int> ref;
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

TraceMap GC_DEBUG_AllocatedObjects;

void  __GC_DEBUG_COLLECT_LEAK_INFO() {
    if (GC_DEBUG) {
        for (auto r : GC_DEBUG_AllocatedObjects.ref) {
            if (r.second != 0) {
                fprintf(stderr, "GC Leak: %p\n", r.first);
            }
        }
    }
}

DObject::DObject() {
    ref_cnt = 1;
    if (GC_DEBUG) {
        fprintf(stderr, "GC Debug: %p is created\n", this);
        GC_DEBUG_AllocatedObjects.ref[this] = 1;
    }
}

void DObject::IncRef() {
    this->ref_lock.lock();
    this->ref_cnt++;
    if (GC_DEBUG) {
        fprintf(stderr, "GC Debug: ref cnt of %s, %p is incremented to %d\n", name(), this, this->ref_cnt);
        GC_DEBUG_AllocatedObjects.ref[this]++;
    }
    this->ref_lock.unlock();
}

void DObject::DecRef() {
    this->ref_lock.lock();
    this->ref_cnt--;
    if (GC_DEBUG) {
        fprintf(stderr, "GC Debug: ref cnt of %s, %p is decremented to %d\n", name(), this, this->ref_cnt);
        GC_DEBUG_AllocatedObjects.ref[this]--;
    }
    if (this->ref_cnt < 0) {
        fprintf(stderr, "using an already released object\n");
        exit(1);
    }
    if (this->ref_cnt == 0) {
        this->ref_lock.unlock();
        delete this;
    } else {
        this->ref_lock.unlock();
    }
}
