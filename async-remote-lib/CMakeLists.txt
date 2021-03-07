project(async-remote-lib)
cmake_minimum_required(VERSION 3.14)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread" )

include_directories(src)

add_subdirectory(src)
add_subdirectory(test)
add_subdirectory(lib/googletest)

#  CMake control options
################################################################################
#option(ENABLE_TEST "Build the unit test library" ON)
#option(BUILD_GTEST_MODULE_TEST "Build test for gtest module" OFF)
#################################################################################
#
#enable_testing()
#find_package(GTest REQUIRED)
#include_directories(${GTEST_INCLUDE_DIRS})
#
## gtest
#################################################################################
#include_directories("${CMAKE_CURRENT_SOURCE_DIR}/googletest/googletest/include")
#include_directories("${CMAKE_CURRENT_SOURCE_DIR}/googletest/googlemock/include")
#################################################################################
#
#file(GLOB SOURCE_FILES_CPP RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "*.cpp")
#file(GLOB SOURCE_FILES_C RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "*.c")
#list(FILTER SOURCE_FILES_CPP EXCLUDE REGEX ".*main.cpp")
#file(GLOB ENTRY_FILE "src/main.cpp")
#file(GLOB TEST_SOURCE_FILES "${CMAKE_CURRENT_SOURCE_DIR}/*_test.cpp")
#file(GLOB TEST_MAIN "${CMAKE_CURRENT_SOURCE_DIR}/test/main.cpp")
#
#
#add_executable(unittest ${TEST_SOURCE_FILES} ${SOURCE_FILES_CPP} ${SOURCE_FILES_C} ${TEST_MAIN})
#add_executable(async-remote-lib ${SOURCE_FILES_CPP} ${SOURCE_FILES_C} ${ENTRY_FILE})
#
#
