set(CMAKE_SYSTEM_NAME Darwin)
set(CMAKE_SYSTEM_PROCESSOR i386)
set(CMAKE_SYSTEM_VERSION 15)

set(triplet "${CMAKE_SYSTEM_PROCESSOR}-apple-darwin${CMAKE_SYSTEM_VERSION}")
math(EXPR sdkver "${CMAKE_SYSTEM_VERSION} - 4")

set(CMAKE_SYSROOT "/foreign/MacOSX10.${sdkver}.sdk")
list(APPEND CMAKE_PREFIX_PATH "/usr/lib/llvm-9.0/bin")

find_program(CMAKE_C_COMPILER NAMES ${triplet}-clang clang)
find_program(CMAKE_CXX_COMPILER NAMES ${triplet}-clang++-libc++ ${triplet}-clang++ clang++)

find_program(CMAKE_AR NAMES ${triplet}-ar llvm-ar)
find_program(CMAKE_RANLIB NAMES ${triplet}-ranlib llvm-ranlib)
find_program(CMAKE_STRIP NAMES ${triplet}-strip llvm-strip)
find_program(CMAKE_LINKER NAMES ${triplet}-ld ld64.lld)
find_program(CMAKE_NM NAMES ${triplet}-nm llvm-nm)
find_program(CMAKE_INSTALL_NAME_TOOL NAMES ${triplet}-install_name_tool install_name_tool)

set(CMAKE_C_COMPILER_TARGET ${triplet})
set(CMAKE_CXX_COMPILER_TARGET ${triplet})

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
