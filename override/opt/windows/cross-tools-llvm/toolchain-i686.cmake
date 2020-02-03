set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR i686)
set(CMAKE_SYSTEM_VERSION 10)

set(triplet "${CMAKE_SYSTEM_PROCESSOR}-w64-mingw32")

set(CMAKE_SYSROOT "$ENV{WINEPREFIX}/drive_c")
list(APPEND CMAKE_PREFIX_PATH "/opt/windows/cross-tools-llvm")

find_program(CMAKE_C_COMPILER NAMES ${triplet}-clang)
find_program(CMAKE_CXX_COMPILER NAMES ${triplet}-clang++)
find_program(CMAKE_RC_COMPILER NAMES ${triplet}-windres)

find_program(CMAKE_AR NAMES ${triplet}-ar)
find_program(CMAKE_RANLIB NAMES ${triplet}-ranlib)
find_program(CMAKE_STRIP NAMES ${triplet}-strip)
find_program(CMAKE_LINKER NAMES ${triplet}-ld)
find_program(CMAKE_NM NAMES ${triplet}-nm)
find_program(CMAKE_OBJDUMP NAMES ${triplet}-objdump)
find_program(CMAKE_OBJCOPY NAMES ${triplet}-objcopy)
find_program(CMAKE_DLLTOOL NAMES ${triplet}-dlltool)
find_program(CMAKE_ADDR2LINE NAMES ${triplet}-addr2line)

set(CMAKE_C_COMPILER_TARGET ${triplet})
set(CMAKE_C_FLAGS_INIT "-rtlib=compiler-rt")
set(CMAKE_CXX_COMPILER_TARGET ${triplet})
set(CMAKE_CXX_FLAGS_INIT "-rtlib=compiler-rt -stdlib=libc++")

set(CMAKE_EXE_LINKER_FLAGS_INIT "-fuse-ld=lld")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "-fuse-ld=lld")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "-fuse-ld=lld")

find_program(CMAKE_CROSSCOMPILING_EMULATOR NAMES wine64 wine)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)