set(CMAKE_SYSTEM_NAME Haiku)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR i586)
set(CMAKE_SIZEOF_VOID_P 4)

set(triplet "${CMAKE_SYSTEM_PROCESSOR}-pc-haiku")

set(CMAKE_SYSROOT "$ENV{HAIKU_SYSROOT_X86}")
list(APPEND CMAKE_PREFIX_PATH "$ENV{HAIKU_TOOLCHAIN_X86}" "$ENV{HAIKU_TOOLCHAIN_X86}/${triplet}")

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

set(CMAKE_LIBRARY_ARCHITECTURE "x86")
set(CMAKE_C_LIBRARY_ARCHITECTURE ${CMAKE_LIBRARY_ARCHITECTURE})
set(CMAKE_CXX_LIBRARY_ARCHITECTURE ${CMAKE_LIBRARY_ARCHITECTURE})

set(CMAKE_C_COMPILER_TARGET ${triplet})
set(CMAKE_C_FLAGS_INIT "-march=i586 -mmmx -mfpmath=387 -mtune=pentium2")
set(CMAKE_CXX_COMPILER_TARGET ${triplet})
set(CMAKE_CXX_FLAGS_INIT "-march=i586 -mmmx -mfpmath=387 -mtune=pentium2")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
