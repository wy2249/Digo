/* gc.h provides a C++ base class for Digo objects that need reference count gc.
 *
 * Digo Slice and Digo String are wrapped in this gc template.
 *
 * Author: sh4081
 * Date: 2021/3/25
 */

#ifndef DIGO_LINKER_GC_H
#define DIGO_LINKER_GC_H

// #define ENABLE_GC_DEBUG

#ifdef ENABLE_GC_DEBUG

const bool GC_DEBUG = true;

#else

const bool GC_DEBUG = false;

#endif

#include <mutex>
#include <memory>

/*  A Digo object with ref count GC support  */
class DObject {
protected:
    std::mutex ref_lock;
    int ref_cnt = 0;

public:
    virtual ~DObject() = default;

    /*   overrides this function to provide the name of the object;
     *   for debugging purpose.
     */
    virtual const char* name() {
        return "Base Object";
    }

    DObject();
    virtual void IncRef() final;
    virtual void DecRef() final;
};


extern "C" {
void __GC_DecRef(void* obj);
void* __GC_CreateTraceMap();
void  __GC_Trace(void* map, void* obj);
void  __GC_NoTrace(void* map, void* obj);
void  __GC_ReleaseAll(void* map);

void  __GC_DEBUG_COLLECT_LEAK_INFO();
}

#endif //DIGO_LINKER_GC_H
