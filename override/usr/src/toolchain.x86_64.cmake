set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR x86_64)
set(CMAKE_SIZEOF_VOID_P 8)

set(triplet "${CMAKE_SYSTEM_PROCESSOR}-linux-gnu")

list(APPEND CMAKE_PREFIX_PATH "/usr/${triplet}")

find_program(CMAKE_C_COMPILER NAMES ${triplet}-gcc)
find_program(CMAKE_CXX_COMPILER NAMES ${triplet}-g++)

find_program(CMAKE_AR NAMES ${triplet}-gcc-ar ${triplet}-ar)
find_program(CMAKE_RANLIB NAMES ${triplet}-gcc-ranlib ${triplet}-ranlib)
find_program(CMAKE_STRIP NAMES ${triplet}-strip)
find_program(CMAKE_LINKER NAMES ${triplet}-ld)
find_program(CMAKE_NM NAMES ${triplet}-gcc-nm ${triplet}-nm)
find_program(CMAKE_OBJDUMP NAMES ${triplet}-objdump)
find_program(CMAKE_OBJCOPY NAMES ${triplet}-objcopy)
find_program(CMAKE_READELF NAMES ${triplet}-readelf)
find_program(CMAKE_ADDR2LINE NAMES ${triplet}-addr2line)

set(CMAKE_C_COMPILER_TARGET ${triplet})
set(CMAKE_C_FLAGS_INIT "-m64 -march=x86-64 -msse3 -mssse3 -msse4.1 -msse4.2 -mavx -maes -mpclmul -mtune=haswell")
set(CMAKE_CXX_COMPILER_TARGET ${triplet})
set(CMAKE_CXX_FLAGS_INIT "-m64 -march=x86-64 -msse3 -mssse3 -msse4.1 -msse4.2 -mavx -maes -mpclmul -mtune=haswell")

set(CMAKE_EXE_LINKER_FLAGS_INIT "-fuse-ld=gold")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "-fuse-ld=gold")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "-fuse-ld=gold")