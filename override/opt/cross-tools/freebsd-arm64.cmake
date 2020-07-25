set(CMAKE_SYSTEM_NAME FreeBSD)
set(CMAKE_SYSTEM_PROCESSOR aarch64)
set(CMAKE_SYSTEM_VERSION $ENV{FREEBSD_DEPLOYMENT_TARGET})
set(CMAKE_SIZEOF_VOID_P 8)

set(triplet "${CMAKE_SYSTEM_PROCESSOR}-unknown-freebsd${CMAKE_SYSTEM_VERSION}")

set(CMAKE_SYSROOT "$ENV{FREEBSD_SYSROOT_ARM64}")
list(APPEND CMAKE_PREFIX_PATH "/usr/lib/llvm-$ENV{LLVM_MAJOR}")

find_program(CMAKE_C_COMPILER NAMES clang)
find_program(CMAKE_CXX_COMPILER NAMES clang++)

find_program(CMAKE_AR NAMES llvm-ar)
find_program(CMAKE_RANLIB NAMES llvm-ranlib)
find_program(CMAKE_STRIP NAMES llvm-strip)
find_program(CMAKE_LINKER NAMES ld.lld)
find_program(CMAKE_NM NAMES llvm-nm)
find_program(CMAKE_OBJDUMP NAMES llvm-objdump)
find_program(CMAKE_OBJCOPY NAMES llvm-objcopy)
find_program(CMAKE_READELF NAMES llvm-readelf)
find_program(CMAKE_ADDR2LINE NAMES llvm-addr2line)

set(CMAKE_C_COMPILER_TARGET ${triplet})
set(CMAKE_C_FLAGS_INIT "-march=armv8-a+fp+simd -mtune=cortex-a53 -rtlib=compiler-rt")
set(CMAKE_CXX_COMPILER_TARGET ${triplet})
set(CMAKE_C_FLAGS_INIT "-march=armv8-a+fp+simd -mtune=cortex-a53 -rtlib=compiler-rt -stdlib=libc++")

set(CMAKE_EXE_LINKER_FLAGS_INIT "-fuse-ld=lld -rtlib=compiler-rt")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "-fuse-ld=lld -rtlib=compiler-rt")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "-fuse-ld=lld -rtlib=compiler-rt")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
