/* gc.h provides a C++ template for Digo objects that need reference count gc.
 *
 * Digo Slice and Digo String are wrapped in this gc template.
 *
 * Author: sh4081
 * Date: 2021/3/25
 */

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

/*  A Digo object with ref count GC support  */
template <typename T>
class DObject {
private:
    /*  the layout is fixed , so we can do IncRef/DecRef regardless
     *  of the actual object type. */
    std::mutex ref_lock;
    int ref_cnt = 0;

public:
    DObject() = default;
    virtual ~DObject() = default;

    static DObject<T>* Create(T* ptr) {
        return Create(std::shared_ptr<T>(ptr));
    }

    static DObject<T>* Create(std::shared_ptr<T> ptr) {
        auto ret = new DObject();
        ret->obj_ = ptr;
        ret->ref_cnt = 1;
        if (GC_DEBUG) {
            fprintf(stderr, "GC Debug: %s, %p is created\n", typeid(T).name(), ret);
        }
        return ret;
    }

    void IncRef() {
        this->ref_lock.lock();
        this->ref_cnt++;
        if (GC_DEBUG) {
            fprintf(stderr, "GC Debug: ref cnt of %s, %p is incremented to %d\n", typeid(T).name(), this, this->ref_cnt);
        }
        this->ref_lock.unlock();
    }

    void DecRef() {
        this->ref_lock.lock();
        this->ref_cnt--;
        if (GC_DEBUG) {
            fprintf(stderr, "GC Debug: ref cnt of %s, %p is decremented to %d\n", typeid(T).name(), this, this->ref_cnt);
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
};


#endif //DIGO_LINKER_GC_H
