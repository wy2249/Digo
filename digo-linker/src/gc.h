//
// Created by VM on 2021/3/25.
//

#ifndef DIGO_LINKER_GC_H
#define DIGO_LINKER_GC_H

#define ENABLE_GC_DEBUG

#ifdef ENABLE_GC_DEBUG

const bool GC_DEBUG = true;

#else

const bool GC_DEBUG = false;

#endif

#include <mutex>
#include <memory>

// gc.h provides a C++ template for objects that need reference count gc.

// Wraps the data with a multi-thread safe reference counter
template <typename T> class ref_wrapper {
public:
    std::shared_ptr<T> any_data;
    std::mutex ref_lock;
    std::mutex data_lock;
    int ref_cnt = 0;
};

// these two APIs provide the lock for the data in a reference wrapper.
template <typename T>
void* AcquireLock(ref_wrapper<T>* ref) {
    ref->data_lock.lock();
    return ref->any_data;
}

template <typename T>
void ReleaseLock(ref_wrapper<T>* ref) {
    ref->data_lock.unlock();
}

template <typename T>
void* GC_Create(std::shared_ptr<T> data) {
    auto refTemplate = new ref_wrapper<T>;
    refTemplate->any_data = data;
    refTemplate->ref_cnt = 1;
    return refTemplate;
}

template <typename T>
void GC_IncRef(ref_wrapper<T>* ref) {
    ref->ref_lock.lock();
    ref->ref_cnt++;
    if (GC_DEBUG) {
        printf("GC Debug: ref cnt of %s, %p is incremented to %d\n", typeid(T).name(), ref, ref->ref_cnt);
    }
    ref->ref_lock.unlock();
}

template <typename T>
void GC_DecRef(ref_wrapper<T>* r) {
    r->ref_lock.lock();
    r->ref_cnt--;
    if (GC_DEBUG) {
        printf("GC Debug: ref cnt of %s, %p is decremented to %d\n", typeid(T).name(), r, r->ref_cnt);
    }
    if (r->ref_cnt < 0) {
        printf("using an already released object\n");
        exit(1);
    }
    if (r->ref_cnt == 0) {
        r->ref_lock.unlock();
        delete r;
    } else {
        r->ref_lock.unlock();
    }
}

#endif //DIGO_LINKER_GC_H
