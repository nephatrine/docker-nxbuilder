set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR s390x)
set(triplet s390x-linux-gnu)

list(APPEND CMAKE_PREFIX_PATH "/usr/${triplet}")

set(CMAKE_C_COMPILER ${triplet}-gcc)
set(CMAKE_C_LIBRARY_ARCHITECTURE ${triplet})
set(CMAKE_CXX_COMPILER ${triplet}-g++)
set(CMAKE_CXX_LIBRARY_ARCHITECTURE ${triplet})

find_program(CMAKE_AR ${triplet}-ar)
find_program(CMAKE_RANLIB ${triplet}-ranlib)
find_program(CMAKE_NM ${triplet}-nm)
find_program(CMAKE_OBJCOPY ${triplet}-objcopy)
find_program(CMAKE_OBJDUMP ${triplet}-objdump)
find_program(CMAKE_STRIP ${triplet}-strip)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
