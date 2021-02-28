# cmake_minimum_required(VERSION <specify CMake version here>)
project(async-remote-lib)

set(CMAKE_CXX_STANDARD 20)

add_executable(async-remote-lib main.cpp network.cpp network.h async.cpp async.h common.h linker_common.h linker_reserved.c)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread" )
