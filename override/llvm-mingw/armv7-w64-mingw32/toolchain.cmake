set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR armv7)
set(triplet armv7-w64-mingw32)

set(CMAKE_SYSROOT "/llvm-mingw/${triplet}")
list(APPEND CMAKE_PREFIX_PATH "/llvm-mingw")
list(APPEND CMAKE_FIND_ROOT_PATH "/llvm-mingw/generic-w64-mingw32")

set(CMAKE_C_COMPILER ${triplet}-clang)
set(CMAKE_C_COMPILER_TARGET ${triplet})
set(CMAKE_CXX_COMPILER ${triplet}-clang++)
set(CMAKE_CXX_COMPILER_TARGET ${triplet})
set(CMAKE_RC_COMPILER ${triplet}-windres)

find_program(CMAKE_AR ${triplet}-ar)
find_program(CMAKE_RANLIB ${triplet}-ranlib)
find_program(CMAKE_NM ${triplet}-nm)
find_program(CMAKE_OBJCOPY ${triplet}-objcopy)
find_program(CMAKE_OBJDUMP ${triplet}-objdump)
find_program(CMAKE_STRIP ${triplet}-strip)

set(CMAKE_CXX_FLAGS_INIT "-stdlib=libc++")
set(CMAKE_EXE_LINKER_FLAGS_INIT "-fuse-ld=lld")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
