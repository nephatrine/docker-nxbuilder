set(CMAKE_SYSTEM_NAME FreeBSD)
set(CMAKE_SYSTEM_PROCESSOR i386)
set(CMAKE_SYSTEM_VERSION $ENV{FREEBSD_VERSION})
set(CMAKE_SIZEOF_VOID_P 4)

set(triplet "${CMAKE_SYSTEM_PROCESSOR}-unknown-freebsd${CMAKE_SYSTEM_VERSION}")

set(CMAKE_SYSROOT "$ENV{FREEBSD_SYSROOT_IA32}")
list(APPEND CMAKE_PREFIX_PATH "/usr/lib/llvm-$ENV{LLVM_MAJOR}")

find_program(CMAKE_C_COMPILER NAMES "clang-$ENV{LLVM_MAJOR}" clang)
find_program(CMAKE_CXX_COMPILER NAMES "clang++-$ENV{LLVM_MAJOR}" clang++)

find_program(CMAKE_AR NAMES "llvm-ar-$ENV{LLVM_MAJOR}" llvm-ar)
find_program(CMAKE_RANLIB NAMES "llvm-ranlib-$ENV{LLVM_MAJOR}" llvm-ranlib)
find_program(CMAKE_STRIP NAMES "llvm-strip-$ENV{LLVM_MAJOR}" llvm-strip)
find_program(CMAKE_LINKER NAMES "ld.lld-$ENV{LLVM_MAJOR}" ld.lld)
find_program(CMAKE_NM NAMES "llvm-nm-$ENV{LLVM_MAJOR}" llvm-nm)
find_program(CMAKE_OBJDUMP NAMES "llvm-objdump-$ENV{LLVM_MAJOR}" llvm-objdump)
find_program(CMAKE_OBJCOPY NAMES "llvm-objcopy-$ENV{LLVM_MAJOR}" llvm-objcopy)
find_program(CMAKE_READELF NAMES "llvm-readelf-$ENV{LLVM_MAJOR}" llvm-readelf)
find_program(CMAKE_ADDR2LINE NAMES "llvm-addr2line-$ENV{LLVM_MAJOR}" llvm-addr2line)

set(CMAKE_C_COMPILER_TARGET ${triplet})
set(CMAKE_C_FLAGS_INIT "-march=i686 -mmmx -msse -mtune=pentium4 -mfpmath=sse")
set(CMAKE_CXX_COMPILER_TARGET ${triplet})
set(CMAKE_C_FLAGS_INIT "-march=i686 -mmmx -msse -mtune=pentium4 -mfpmath=sse -stdlib=libc++")

set(CMAKE_EXE_LINKER_FLAGS_INIT "-fuse-ld=lld -rtlib=compiler-rt")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "-fuse-ld=lld -rtlib=compiler-rt")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "-fuse-ld=lld -rtlib=compiler-rt")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
