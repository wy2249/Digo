project(digo-linker)
cmake_minimum_required(VERSION 3.14)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread" )

add_executable(digo-linker src/wrapper.cpp src/serialization.cpp src/main.cpp src/metadata.cpp src/serialization_wrapper.cpp src/auto_gc.cpp src/auto_gc.h ../async-remote-lib/src/dstring.cpp ../async-remote-lib/src/dslice.cpp src/print_funcs.cpp)

include_directories(src)
