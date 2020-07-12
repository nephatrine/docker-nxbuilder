set(CMAKE_SYSTEM_NAME Haiku)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

set(triplet "${CMAKE_SYSTEM_PROCESSOR}-unknown-haiku")

set(CMAKE_SYSROOT "$ENV{HAIKU_INSTALL_DIR}")
list(APPEND CMAKE_PREFIX_PATH "$ENV{TOOLCHAIN_PREFIX}" "$ENV{TOOLCHAIN_PREFIX}/${triplet}")

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
set(CMAKE_C_LIBRARY_ARCHITECTURE ${CMAKE_SYSTEM_PROCESSOR})
set(CMAKE_CXX_COMPILER_TARGET ${triplet})
set(CMAKE_CXX_LIBRARY_ARCHITECTURE ${CMAKE_SYSTEM_PROCESSOR})

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)