set(CMAKE_SYSTEM_NAME FreeBSD)
set(CMAKE_SYSTEM_PROCESSOR __ARCHITECTURE__)

set(CMAKE_SYSROOT "/usr/${CMAKE_SYSTEM_PROCESSOR}-freebsd-current")
set(CMAKE_STAGING_PREFIX "${CMAKE_SYSROOT}/nxb")

set(CMAKE_C_COMPILER clang)
set(CMAKE_C_COMPILER_TARGET ${CMAKE_SYSTEM_PROCESSOR}-unknown-freebsdVERSION)
set(CMAKE_CXX_COMPILER clang++)
set(CMAKE_CXX_COMPILER_TARGET ${CMAKE_SYSTEM_PROCESSOR}-unknown-freebsdVERSION)

find_program(CMAKE_AR llvm-ar)
find_program(CMAKE_RANLIB llvm-ranlib)
find_program(CMAKE_NM llvm-nm)
find_program(CMAKE_OBJCOPY llvm-objcopy)
find_program(CMAKE_OBJDUMP llvm-objdump)
find_program(CMAKE_STRIP llvm-strip)

set(CMAKE_CXX_FLAGS_INIT "-stdlib=libc++")
set(CMAKE_EXE_LINKER_FLAGS_INIT "-fuse-ld=lld")

set(CMAKE_FIND_ROOT_PATH "${CMAKE_STAGING_PREFIX};${CMAKE_SYSROOT}")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
