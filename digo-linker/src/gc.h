/* gc.h provides a C++ base class for Digo objects that need reference count gc.
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
class DObject {
private:
    std::mutex ref_lock;
    int ref_cnt = 0;

    const char* type_;

public:
    virtual ~DObject() = default;

    DObject() {
        type_ = typeid(this).name();
        ref_cnt = 1;
        if (GC_DEBUG) {
            fprintf(stderr, "GC Debug: %s, %p is created\n", type_, this);
        }
    }

    void IncRef() {
        this->ref_lock.lock();
        this->ref_cnt++;
        if (GC_DEBUG) {
            fprintf(stderr, "GC Debug: ref cnt of %s, %p is incremented to %d\n", type_, this, this->ref_cnt);
        }
        this->ref_lock.unlock();
    }

    void DecRef() {
        this->ref_lock.lock();
        this->ref_cnt--;
        if (GC_DEBUG) {
            fprintf(stderr, "GC Debug: ref cnt of %s, %p is decremented to %d\n", type_, this, this->ref_cnt);
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

};


#endif //DIGO_LINKER_GC_H
