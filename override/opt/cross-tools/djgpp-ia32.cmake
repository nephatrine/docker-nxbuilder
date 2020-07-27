set(CMAKE_SYSTEM_NAME MSDOS)
set(CMAKE_SYSTEM_PROCESSOR i586)
set(CMAKE_SIZEOF_VOID_P 4)

set(triplet "${CMAKE_SYSTEM_PROCESSOR}-pc-msdosdjgpp")

list(APPEND CMAKE_PREFIX_PATH "$ENV{DJGPP_PREFIX}" "$ENV{DJGPP_PREFIX}/${triplet}")

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
find_program(CMAKE_DXEGEN NAMES ${triplet}-dxe3gen ${triplet}-dxegen dxe3gen dxegen)

set(CMAKE_C_COMPILER_TARGET ${triplet})
set(CMAKE_C_FLAGS_INIT "-march=i586 -mmmx -mfpmath=387 -mtune=pentium2")
set(CMAKE_CXX_COMPILER_TARGET ${triplet})
set(CMAKE_CXX_FLAGS_INIT "-march=i586 -mmmx -mfpmath=387 -mtune=pentium2")
