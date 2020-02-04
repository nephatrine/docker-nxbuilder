set(CMAKE_SYSTEM_NAME Darwin)
set(CMAKE_SYSTEM_PROCESSOR i386)
set(CMAKE_OSX_ARCHITECTURES ${CMAKE_SYSTEM_PROCESSOR})

string(REPLACE "." ";" OSX_SDK_VERSION "$ENV{SDK_VERSION}")
list(GET OSX_SDK_VERSION 1 CMAKE_SYSTEM_VERSION)
math(EXPR CMAKE_SYSTEM_VERSION "${CMAKE_SYSTEM_VERSION} + 4")

set(triplet "${CMAKE_SYSTEM_PROCESSOR}-apple-darwin${CMAKE_SYSTEM_VERSION}")

set(CMAKE_OSX_SYSROOT "/opt/darwin/sysroot-osx")
list(APPEND CMAKE_PREFIX_PATH "/opt/darwin/cross-tools-llvm")

find_program(CMAKE_C_COMPILER NAMES ${triplet}-clang)
find_program(CMAKE_CXX_COMPILER NAMES ${triplet}-clang++)

find_program(CMAKE_AR NAMES ${triplet}-ar)
find_program(CMAKE_RANLIB NAMES ${triplet}-ranlib)
find_program(CMAKE_STRIP NAMES ${triplet}-strip)
find_program(CMAKE_LINKER NAMES ${triplet}-ld)
find_program(CMAKE_NM NAMES ${triplet}-nm)
find_program(CMAKE_INSTALL_NAME_TOOL NAMES ${triplet}-install_name_tool)

set(CMAKE_C_COMPILER_TARGET ${triplet})
set(CMAKE_C_FLAGS_INIT "-rtlib=compiler-rt")
set(CMAKE_CXX_COMPILER_TARGET ${triplet})
set(CMAKE_CXX_FLAGS_INIT "-rtlib=compiler-rt -stdlib=libc++")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
