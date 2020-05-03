set(CMAKE_SYSTEM_NAME SunOS)
set(CMAKE_SYSTEM_PROCESSOR x86_64)
set(CMAKE_SYSTEM_VERSION $ENV{SOLARIS_VERSION})

string(REPLACE "." ";" CMAKE_SYSTEM_VERSION_LIST "${CMAKE_SYSTEM_VERSION}")
list(GET CMAKE_SYSTEM_VERSION_LIST 0 CMAKE_SYSTEM_VERSION_MAJOR)
list(GET CMAKE_SYSTEM_VERSION_LIST 1 CMAKE_SYSTEM_VERSION_MINOR)
math(EXPR CMAKE_SYSTEM_VERSION_MAJOR "${CMAKE_SYSTEM_VERSION_MAJOR} - 3")

set(triplet64 "${CMAKE_SYSTEM_PROCESSOR}-pc-solaris${CMAKE_SYSTEM_VERSION_MAJOR}.${CMAKE_SYSTEM_VERSION_MINOR}")
set(triplet32 "i386-pc-solaris${CMAKE_SYSTEM_VERSION_MAJOR}.${CMAKE_SYSTEM_VERSION_MINOR}")

set(CMAKE_SYSROOT "$ENV{SOLARIS_PREFIX}/sysroot")
list(APPEND CMAKE_PREFIX_PATH "$ENV{SOLARIS_PREFIX}")

find_program(CMAKE_C_COMPILER NAMES ${triplet64}-gcc ${triplet32}-gcc)
find_program(CMAKE_CXX_COMPILER NAMES ${triplet64}-g++ ${triplet32}-g++)

find_program(CMAKE_AR NAMES ${triplet64}-gcc-ar ${triplet64}-ar ${triplet32}-gcc-ar ${triplet32}-ar)
find_program(CMAKE_RANLIB NAMES ${triplet64}-gcc-ranlib ${triplet64}-ranlib ${triplet32}-gcc-ranlib ${triplet32}-ranlib)
find_program(CMAKE_STRIP NAMES ${triplet64}-strip ${triplet32}-strip)
find_program(CMAKE_LINKER NAMES ${triplet64}-ld ${triplet32}-ld)
find_program(CMAKE_NM NAMES ${triplet64}-gcc-nm ${triplet64}-nm ${triplet32}-gcc-nm ${triplet32}-nm)
find_program(CMAKE_OBJDUMP NAMES ${triplet64}-objdump ${triplet32}-objdump)
find_program(CMAKE_OBJCOPY NAMES ${triplet64}-objcopy ${triplet32}-objcopy)
find_program(CMAKE_READELF NAMES ${triplet64}-readelf ${triplet32}-readelf)
find_program(CMAKE_ADDR2LINE NAMES ${triplet64}-addr2line ${triplet32}-addr2line)

set(CMAKE_C_COMPILER_TARGET ${triplet64})
set(CMAKE_CXX_COMPILER_TARGET ${triplet64})

set(CMAKE_C_FLAGS_INIT "-m64")
set(CMAKE_CXX_FLAGS_INIT "-m64")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
