set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR x86_64)
set(CMAKE_SYSTEM_VERSION 10)

set(triplet "${CMAKE_SYSTEM_PROCESSOR}-w64-mingw32")

set(CMAKE_SYSROOT "/opt/llvm-mingw/${triplet}")
list(APPEND CMAKE_PREFIX_PATH "/opt/llvm-mingw" "/usr/lib/llvm-9.0/bin")
list(APPEND CMAKE_FIND_ROOT_PATH "/opt/llvm-mingw/generic-w64-mingw32")

find_program(CMAKE_C_COMPILER NAMES ${triplet}-clang clang)
find_program(CMAKE_CXX_COMPILER NAMES ${triplet}-clang++ clang++)
find_program(CMAKE_RC_COMPILER NAMES ${triplet}-windres windres)

find_program(CMAKE_AR NAMES ${triplet}-ar llvm-ar)
find_program(CMAKE_RANLIB NAMES ${triplet}-ranlib llvm-ranlib)
find_program(CMAKE_STRIP NAMES ${triplet}-strip llvm-strip)
find_program(CMAKE_LINKER NAMES ${triplet}-ld ld.lld)
find_program(CMAKE_NM NAMES ${triplet}-nm llvm-nm)
find_program(CMAKE_OBJDUMP NAMES ${triplet}-objdump llvm-objdump)
find_program(CMAKE_OBJCOPY NAMES ${triplet}-objcopy llvm-objcopy)
find_program(CMAKE_ADDR2LINE NAMES ${triplet}-addr2line llvm-addr2line)

set(CMAKE_C_COMPILER_TARGET ${triplet})
set(CMAKE_C_FLAGS_INIT "-rtlib=compiler-rt")
set(CMAKE_CXX_COMPILER_TARGET ${triplet})
set(CMAKE_CXX_FLAGS_INIT "-rtlib=compiler-rt -stdlib=libc++")

set(CMAKE_EXE_LINKER_FLAGS_INIT "-fuse-ld=lld")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "-fuse-ld=lld")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "-fuse-ld=lld")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
