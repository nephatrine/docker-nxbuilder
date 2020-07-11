set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR x86_64)
set(CMAKE_SYSTEM_VERSION 10)

set(triplet "${CMAKE_SYSTEM_PROCESSOR}-w64-mingw32")

set(CMAKE_SYSROOT "$ENV{WINEPREFIX}/drive_c")
list(APPEND CMAKE_PREFIX_PATH "/usr/${triplet}")

find_program(CMAKE_C_COMPILER NAMES ${triplet}-gcc)
find_program(CMAKE_CXX_COMPILER NAMES ${triplet}-g++)
find_program(CMAKE_RC_COMPILER NAMES ${triplet}-windres)

find_program(CMAKE_AR NAMES ${triplet}-gcc-ar ${triplet}-ar)
find_program(CMAKE_RANLIB NAMES ${triplet}-gcc-ranlib ${triplet}-ranlib)
find_program(CMAKE_STRIP NAMES ${triplet}-strip)
find_program(CMAKE_LINKER NAMES ${triplet}-ld)
find_program(CMAKE_NM NAMES ${triplet}-gcc-nm ${triplet}-nm)
find_program(CMAKE_OBJDUMP NAMES ${triplet}-objdump)
find_program(CMAKE_OBJCOPY NAMES ${triplet}-objcopy)
find_program(CMAKE_DLLTOOL NAMES ${triplet}-dlltool)
find_program(CMAKE_ADDR2LINE NAMES ${triplet}-addr2line)

set(CMAKE_C_COMPILER_TARGET ${triplet})
set(CMAKE_C_LIBRARY_ARCHITECTURE ${triplet})
set(CMAKE_CXX_COMPILER_TARGET ${triplet})
set(CMAKE_CXX_LIBRARY_ARCHITECTURE ${triplet})

find_program(CMAKE_CROSSCOMPILING_EMULATOR NAMES wine64 wine)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
