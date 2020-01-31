set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR armv7)
set(CMAKE_SYSTEM_VERSION 10.0)

set(triplet "${CMAKE_SYSTEM_PROCESSOR}-windows-msvc")

set(CMAKE_SYSROOT "/opt/msvc-wine/${triplet}")
list(APPEND CMAKE_PREFIX_PATH "/usr/lib/llvm-9/bin")
list(APPEND CMAKE_FIND_ROOT_PATH "/opt/llvm-mingw/generic-windows-msvc")

find_program(CMAKE_C_COMPILER NAMES ${triplet}-clang-cl clang-cl)
find_program(CMAKE_CXX_COMPILER NAMES ${triplet}-clang-cl clang-cl)
find_program(CMAKE_RC_COMPILER NAMES ${triplet}-rc llvm-rc)

find_program(CMAKE_MT NAMES ${triplet}-mt llvm-mt)
find_program(CMAKE_AR NAMES ${triplet}-lib llvm-lib)
find_program(CMAKE_RANLIB NAMES ${triplet}-ranlib llvm-ranlib)
find_program(CMAKE_STRIP NAMES ${triplet}-strip llvm-strip)
find_program(CMAKE_LINKER NAMES ${triplet}-link lld-link)
find_program(CMAKE_NM NAMES ${triplet}-nm llvm-nm)
find_program(CMAKE_OBJDUMP NAMES ${triplet}-objdump llvm-objdump)
find_program(CMAKE_OBJCOPY NAMES ${triplet}-objcopy llvm-objcopy)
find_program(CMAKE_ADDR2LINE NAMES ${triplet}-addr2line llvm-addr2line)

set(CMAKE_VS_PLATFORM_NAME arm CACHE STRING "")
set(MSVC_C_ARCHITECTURE_ID "${CMAKE_VS_PLATFORM_NAME}" CACHE STRING "")
set(MSVC_CXX_ARCHITECTURE_ID "${CMAKE_VS_PLATFORM_NAME}" CACHE STRING "")

set(CMAKE_C_COMPILER_TARGET ${triplet})
set(CMAKE_C_FLAGS_INIT "--target=${CMAKE_C_COMPILER_TARGET} -fms-compatibility -fms-compatibility-version=19.24")
set(CMAKE_C_LIBRARY_ARCHITECTURE "${CMAKE_VS_PLATFORM_NAME}")
set(CMAKE_CXX_COMPILER_TARGET ${triplet})
set(CMAKE_CXX_FLAGS_INIT "--target=${CMAKE_CXX_COMPILER_TARGET} -fms-compatibility -fms-compatibility-version=19.24")
set(CMAKE_CXX_LIBRARY_ARCHITECTURE "${CMAKE_VS_PLATFORM_NAME}")

set(CMAKE_C_SIMULATE_ID "MSVC")
set(CMAKE_C_SIMULATE_VERSION 19.24)
set(CMAKE_CXX_SIMULATE_ID "MSVC")
set(CMAKE_CXX_SIMULATE_VERSION 19.24)

set(CMAKE_INCLUDE_SYSTEM_FLAG_C "-imsvc")
set(CMAKE_INCLUDE_SYSTEM_FLAG_CXX "-imsvc")

set(CMAKE_EXE_LINKER_FLAGS_INIT "/manifest:no")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "/manifest:no")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "/manifest:no")

set(CMAKE_USER_MAKE_RULES_OVERRIDE "/opt/msvc-wine/CMakeCompileRules.cmake")
set(CMAKE_TRY_COMPILE_CONFIGURATION "Release")

include_directories(SYSTEM
	"/opt/msvc-wine/vc/tools/msvc/$ENV{MSVCVER}/include"
	"/opt/msvc-wine/kits/10/include/$ENV{SDKVER}/ucrt"
	"/opt/msvc-wine/kits/10/include/$ENV{SDKVER}/shared"
	"/opt/msvc-wine/kits/10/include/$ENV{SDKVER}/um"
	"/opt/msvc-wine/kits/10/include/$ENV{SDKVER}/cppwinrt")
link_directories(
	"/opt/msvc-wine/vc/tools/msvc/$ENV{MSVCVER}/lib/${CMAKE_VS_PLATFORM_NAME}"
	"/opt/msvc-wine/kits/10/lib/$ENV{SDKVER}/ucrt/${CMAKE_VS_PLATFORM_NAME}"
	"/opt/msvc-wine/kits/10/lib/$ENV{SDKVER}/um/${CMAKE_VS_PLATFORM_NAME}")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
