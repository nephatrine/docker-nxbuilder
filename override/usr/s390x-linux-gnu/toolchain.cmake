set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR s390x)

set(triplet "${CMAKE_SYSTEM_PROCESSOR}-linux-gnu")

list(APPEND CMAKE_PREFIX_PATH "/usr/${triplet}")

find_program(CMAKE_C_COMPILER NAMES ${triplet}-gcc gcc)
find_program(CMAKE_CXX_COMPILER NAMES ${triplet}-g++ g++)

find_program(CMAKE_AR NAMES ${triplet}-gcc-ar ${triplet}-ar gcc-ar ar)
find_program(CMAKE_RANLIB NAMES ${triplet}-gcc-ranlib ${triplet}-ranlib gcc-ranlib ranlib)
find_program(CMAKE_STRIP NAMES ${triplet}-strip strip)
find_program(CMAKE_LINKER NAMES ${triplet}-ld ld)
find_program(CMAKE_NM NAMES ${triplet}-gcc-nm ${triplet}-nm gcc-nm nm)
find_program(CMAKE_OBJDUMP NAMES ${triplet}-objdump objdump)
find_program(CMAKE_OBJCOPY NAMES ${triplet}-objcopy objcopy)
find_program(CMAKE_READELF NAMES ${triplet}-readelf readelf)
find_program(CMAKE_ADDR2LINE NAMES ${triplet}-addr2line addr2line)

set(CMAKE_C_COMPILER_TARGET ${triplet})
set(CMAKE_C_LIBRARY_ARCHITECTURE ${triplet})
set(CMAKE_CXX_COMPILER_TARGET ${triplet})
set(CMAKE_CXX_LIBRARY_ARCHITECTURE ${triplet})

set(CMAKE_EXE_LINKER_FLAGS_INIT "-fuse-ld=gold")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "-fuse-ld=gold")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "-fuse-ld=gold")
