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
#include "common.h"

// gc.h provides a C++ template for objects that need reference count gc.

/*  A Digo object with ref count GC support  */
template <typename T>
class DObject {
public:
    DObject() = default;
    virtual ~DObject() = default;

    static void* Create(T* ptr) {
        return Create(std::shared_ptr<T>(ptr));
    }

    static void* Create(std::shared_ptr<T> ptr) {
        auto ret = new DObject();
        ret->obj_ = ptr;
        ret->ref_cnt = 1;
        if (GC_DEBUG) {
            printf("GC Debug: %s, %p is created\n", typeid(T).name(), ret);
        }
        return ret;
    }

    void IncRef() {
        this->ref_lock.lock();
        this->ref_cnt++;
        if (GC_DEBUG) {
            printf("GC Debug: ref cnt of %s, %p is incremented to %d\n", typeid(T).name(), this, this->ref_cnt);
        }
        this->ref_lock.unlock();
    }

    void DecRef() {
        this->ref_lock.lock();
        this->ref_cnt--;
        if (GC_DEBUG) {
            printf("GC Debug: ref cnt of %s, %p is decremented to %d\n", typeid(T).name(), this, this->ref_cnt);
        }
        if (this->ref_cnt < 0) {
            printf("using an already released object\n");
            exit(1);
        }
        if (this->ref_cnt == 0) {
            this->ref_lock.unlock();
            delete this;
        } else {
            this->ref_lock.unlock();
        }
    }

    std::shared_ptr<T> Get() {
        return obj_;
    }

    T* GetPtr() {
        return obj_.get();
    }

    T GetObj() {
        return *obj_;
    }

private:
    std::shared_ptr<T> obj_;
    std::mutex ref_lock;
    int ref_cnt = 0;
};


#endif //DIGO_LINKER_GC_H
