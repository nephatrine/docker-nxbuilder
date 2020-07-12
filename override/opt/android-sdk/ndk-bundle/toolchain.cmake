if(NOT DEFINED ANDROID_NDK)
    set(ANDROID_NDK "$ENV{ANDROID_NDK_ROOT}")
endif()

if(NOT DEFINED ANDROID_STL)
    set(ANDROID_STL "c++_shared")
endif()

if(NOT DEFINED ANDROID_LD)
    set(ANDROID_LD lld)
endif()

if(NOT DEFINED ANDROID_NATIVE_API_LEVEL)
    set(ANDROID_NATIVE_API_LEVEL 24)
endif()

include(${ANDROID_NDK}/build/cmake/android.toolchain.cmake)
