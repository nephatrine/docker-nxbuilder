set(CMAKE_SYSTEM_NAME SunOS)
set(CMAKE_SYSTEM_PROCESSOR x86_64)
set(CMAKE_SYSTEM_VERSION $ENV{OI_DEPLOYMENT_TARGET})
set(CMAKE_SIZEOF_VOID_P 8)

string(REPLACE "." ";" CMAKE_SYSTEM_VERSION_LIST "${CMAKE_SYSTEM_VERSION}")
list(GET CMAKE_SYSTEM_VERSION_LIST 0 CMAKE_SYSTEM_VERSION_MAJOR)
list(GET CMAKE_SYSTEM_VERSION_LIST 1 CMAKE_SYSTEM_VERSION_MINOR)
math(EXPR CMAKE_SYSTEM_VERSION_MAJOR "${CMAKE_SYSTEM_VERSION_MAJOR} - 3")

set(triplet "${CMAKE_SYSTEM_PROCESSOR}-pc-solaris${CMAKE_SYSTEM_VERSION_MAJOR}.${CMAKE_SYSTEM_VERSION_MINOR}")
set(triplet_alt "i386-pc-solaris${CMAKE_SYSTEM_VERSION_MAJOR}.${CMAKE_SYSTEM_VERSION_MINOR}")

set(CMAKE_SYSROOT "$ENV{OI_SYSROOT}")
list(APPEND CMAKE_PREFIX_PATH "$ENV{OI_TOOLCHAIN}")

find_program(CMAKE_C_COMPILER NAMES ${triplet}-gcc ${triplet_alt}-gcc)
find_program(CMAKE_CXX_COMPILER NAMES ${triplet}-g++ ${triplet_alt}-g++)

find_program(CMAKE_AR NAMES ${triplet}-gcc-ar ${triplet}-ar ${triplet_alt}-gcc-ar ${triplet_alt}-ar)
find_program(CMAKE_RANLIB NAMES ${triplet}-gcc-ranlib ${triplet}-ranlib ${triplet_alt}-gcc-ranlib ${triplet_alt}-ranlib)
find_program(CMAKE_STRIP NAMES ${triplet}-strip ${triplet_alt}-strip)
find_program(CMAKE_LINKER NAMES ${triplet}-ld ${triplet_alt}-ld)
find_program(CMAKE_NM NAMES ${triplet}-gcc-nm ${triplet}-nm ${triplet_alt}-gcc-nm ${triplet_alt}-nm)
find_program(CMAKE_OBJDUMP NAMES ${triplet}-objdump ${triplet_alt}-objdump)
find_program(CMAKE_OBJCOPY NAMES ${triplet}-objcopy ${triplet_alt}-objcopy)
find_program(CMAKE_READELF NAMES ${triplet}-readelf ${triplet_alt}-readelf)
find_program(CMAKE_ADDR2LINE NAMES ${triplet}-addr2line ${triplet_alt}-addr2line)

set(CMAKE_LIBRARY_ARCHITECTURE "amd64")
set(CMAKE_C_LIBRARY_ARCHITECTURE ${CMAKE_LIBRARY_ARCHITECTURE})
set(CMAKE_CXX_LIBRARY_ARCHITECTURE ${CMAKE_LIBRARY_ARCHITECTURE})

set(CMAKE_C_COMPILER_TARGET ${triplet})
set(CMAKE_C_FLAGS_INIT "-m64 -march=x86-64 -msse3 -mssse3 -msse4.1 -msse4.2 -mavx -maes -mpclmul -mtune=haswell")
set(CMAKE_CXX_COMPILER_TARGET ${triplet})
set(CMAKE_CXX_FLAGS_INIT "-m64 -march=x86-64 -msse3 -mssse3 -msse4.1 -msse4.2 -mavx -maes -mpclmul -mtune=haswell")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
