set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

set(triplet "${CMAKE_SYSTEM_PROCESSOR}-linux-gnu")

list(APPEND CMAKE_PREFIX_PATH "/usr/lib/llvm-${LLVM_MAJOR}")

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
set(CMAKE_C_FLAGS_INIT "--rtlib=compiler-rt")
set(CMAKE_CXX_COMPILER_TARGET ${triplet})
set(CMAKE_CXX_FLAGS_INIT "--rtlib=compiler-rt -stdlib=libc++")

set(CMAKE_EXE_LINKER_FLAGS_INIT "-fuse-ld=lld --rtlib=compiler-rt -lunwind")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "-fuse-ld=lld --rtlib=compiler-rt -lunwind")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "-fuse-ld=lld --rtlib=compiler-rt -lunwind")
