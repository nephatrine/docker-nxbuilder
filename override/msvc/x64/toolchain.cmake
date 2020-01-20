set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_VERSION 10.0)
set(CMAKE_SYSTEM_PROCESSOR x86_64)
set(triplet x86_64-windows-msvc)
set(winarch x64)

set(_CL_VERSION "19.24.28315")

find_program(CLANG_CL_EXECUTABLE NAMES clang-cl clang-cl-9 clang-cl-8 clang-cl-7)

if(EXISTS "${CLANG_CL_EXECUTABLE}")
	set(CMAKE_C_COMPILER ${CLANG_CL_EXECUTABLE})
	set(CMAKE_C_COMPILER_TARGET ${triplet})
	set(CMAKE_CXX_COMPILER ${CLANG_CL_EXECUTABLE})
	set(CMAKE_CXX_COMPILER_TARGET ${triplet})

	find_program(CMAKE_LINKER NAMES lld-link lld-link-9 lld-link-8 lld-link-7)

	set(CMAKE_C_FLAGS_INIT "--target=${CMAKE_C_COMPILER_TARGET} -fms-compatibility-version=${_CL_VERSION}")
	set(CMAKE_CXX_FLAGS_INIT "--target=${CMAKE_CXX_COMPILER_TARGET} -fms-compatibility-version=${_CL_VERSION}")
	set(CMAKE_INCLUDE_SYSTEM_FLAG_C "-imsvc")
	set(CMAKE_INCLUDE_SYSTEM_FLAG_CXX "-imsvc")
else()
	set(CMAKE_C_COMPILER /msvc/bin/${winarch}/cl)
	set(CMAKE_C_COMPILER_ID MSVC)
	set(CMAKE_C_COMPILER_VERSION ${_CL_VERSION})
	set(CMAKE_CXX_COMPILER /msvc/bin/${winarch}/cl)
	set(CMAKE_CXX_COMPILER_ID MSVC)
	set(CMAKE_CXX_COMPILER_VERSION "${_CL_VERSION}")
	set(CMAKE_RC_COMPILER "/msvc/bin/${winarch}/rc")

	set(CMAKE_AR "/msvc/bin/${winarch}/lib")
	set(CMAKE_LINKER "/msvc/bin/${winarch}/link")
endif()

set(CMAKE_C_LIBRARY_ARCHITECTURE "${winarch}")
set(CMAKE_CXX_LIBRARY_ARCHITECTURE "${winarch}")
set(CMAKE_VS_PLATFORM_NAME "${winarch}")
string(TOUPPER "${winarch}" MSVC_C_ARCHITECTURE_ID)
string(TOUPPER "${winarch}" MSVC_CXX_ARCHITECTURE_ID)

list(APPEND CMAKE_FIND_ROOT_PATH "/msvc" "/msvc/${winarch}" "/msvc/vc/tools/msvc/$ENV{MSVCVER}" "/msvc/kits/10")
include_directories(SYSTEM "/msvc/vc/tools/msvc/$ENV{MSVCVER}/include" "/msvc/kits/10/include/$ENV{SDKVER}/ucrt" "/msvc/kits/10/include/$ENV{SDKVER}/shared" "/msvc/kits/10/include/$ENV{SDKVER}/um" "/msvc/kits/10/include/$ENV{SDKVER}/cppwinrt")
link_directories("/msvc/vc/tools/msvc/$ENV{MSVCVER}/lib/${winarch}" "/msvc/kits/10/lib/$ENV{SDKVER}/ucrt/${winarch}" "/msvc/kits/10/lib/$ENV{SDKVER}/um/${winarch}")

set(CMAKE_EXE_LINKER_FLAGS_INIT "/manifest:no")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "/manifest:no")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "/manifest:no")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
