set(CMAKE_SYSTEM_NAME Darwin)
set(CMAKE_SYSTEM_PROCESSOR x86_64)
set(triplet x86_64-apple-darwin15)

set(CMAKE_SYSROOT "/osx-cross")

set(CMAKE_C_COMPILER o64-clang)
set(CMAKE_C_COMPILER_TARGET ${triplet})
set(CMAKE_CXX_COMPILER o64-clang++)
set(CMAKE_CXX_COMPILER_TARGET ${triplet})

find_program(CMAKE_AR NAMES ${triplet}-ar llvm-ar)
find_program(CMAKE_RANLIB NAMES ${triplet}-ranlib llvm-ranlib)
find_program(CMAKE_STRIP NAMES ${triplet}-strip)
find_program(CMAKE_LINKER NAMES ${triplet}-ld ld.lld)
find_program(CMAKE_NM NAMES ${triplet}-nm llvm-nm)
find_program(CMAKE_OBJDUMP NAMES ${triplet}-objdump llvm-objdump)
find_program(CMAKE_OBJCOPY NAMES ${triplet}-objcopy llvm-objcopy)
find_program(CMAKE_READELF NAMES ${triplet}-readelf llvm-readelf)
find_program(CMAKE_DLLTOOL NAMES ${triplet}-dlltool llvm-dlltool)
find_program(CMAKE_ADDR2LINE NAMES ${triplet}-addr2line llvm-addr2line llvm-addr2line-9 llvm-addr2line-8 llvm-addr2line-7)
find_program(CMAKE_INSTALL_NAME_TOOL NAMES ${triplet}-install_name_tool)

set(CMAKE_CXX_FLAGS_INIT "-stdlib=libc++")
set(CMAKE_EXE_LINKER_FLAGS_INIT "-fuse-ld=lld")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "-fuse-ld=lld")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "-fuse-ld=lld")

list(APPEND CMAKE_FIND_ROOT_PATH "${CMAKE_SYSROOT}/SDK/MacOSXVERSION.sdk")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)