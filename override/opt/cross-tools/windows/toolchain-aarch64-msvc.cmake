function(build_vfs_overlay winsdk_src)
    set(vfs_dest "${winsdk_src}/vfs_overlay.yaml")
    if(NOT EXISTS "${vfs_dest}")
        unset(include_dirs)
        file(
            GLOB_RECURSE entries
            LIST_DIRECTORIES true
            "${winsdk_src}/*")
        foreach(entry ${entries})
            if(IS_DIRECTORY "${entry}")
                list(APPEND include_dirs "${entry}")
            endif()
        endforeach()

        file(WRITE "${vfs_dest}" "version: 0\ncase-sensitive: false\nroots:\n")

        foreach(include_dir ${include_dirs})
            file(
                GLOB headers
                RELATIVE "${include_dir}"
                "${include_dir}/*.h")
            if(NOT headers)
                continue()
            endif()

            file(APPEND "${vfs_dest}" "  - name: \"${include_dir}\"\n    type: directory\n    contents:\n")
            foreach(header ${headers})
                file(
                    APPEND "${vfs_dest}"
                    "      - name: \"${header}\"\n        type: file\n        external-contents: \"${include_dir}/${header}\"\n"
                )
            endforeach()
        endforeach()
    endif()

    set(CMAKE_C_FLAGS_INIT
        "${CMAKE_C_FLAGS_INIT} -Xclang -ivfsoverlay -Xclang \"${vfs_dest}\""
        PARENT_SCOPE)
    set(CMAKE_CXX_FLAGS_INIT
        "${CMAKE_CXX_FLAGS_INIT} -Xclang -ivfsoverlay -Xclang \"${vfs_dest}\""
        PARENT_SCOPE)
endfunction()

function(process_library_path winsdk_src)
    set(winsdk_dest "${winsdk_src}-lc")
    if(NOT EXISTS "${winsdk_dest}")
        execute_process(COMMAND "${CMAKE_COMMAND}" -E make_directory "${winsdk_dest}")
        file(
            GLOB lib_list
            RELATIVE "${winsdk_src}"
            "${winsdk_src}/*")
        foreach(lib_src ${lib_list})
            string(TOLOWER "${lib_src}" lib_dest)
            if(NOT "${lib_src}" STREQUAL "${lib_dest}")
                execute_process(COMMAND "${CMAKE_COMMAND}" -E create_symlink "${winsdk_src}/${lib_src}"
                                        "${winsdk_dest}/${lib_dest}")
            endif()
        endforeach()
    endif()

    link_directories("${winsdk_src}" "${winsdk_dest}")
endfunction()

set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR aarch64)
set(CMAKE_SYSTEM_VERSION ${UCRTVersion})
set(CMAKE_VS_PLATFORM_NAME arm64)

set(triplet "${CMAKE_SYSTEM_PROCESSOR}-windows-msvc")

set(CMAKE_SYSROOT "$ENV{WINEPREFIX}/drive_c")
list(APPEND CMAKE_PREFIX_PATH "$ENV{TOOLCHAIN_PREFIX}")

find_program(CMAKE_C_COMPILER NAMES clang-cl)
find_program(CMAKE_CXX_COMPILER NAMES clang-cl)
find_program(CMAKE_RC_COMPILER NAMES llvm-rc)

find_program(CMAKE_MT NAMES llvm-mt)
find_program(CMAKE_AR NAMES llvm-lib)
find_program(CMAKE_LINKER NAMES lld-link)

set(MSVC_C_ARCHITECTURE_ID "${CMAKE_VS_PLATFORM_NAME}")
set(MSVC_CXX_ARCHITECTURE_ID "${CMAKE_VS_PLATFORM_NAME}")

set(CMAKE_C_COMPILER_TARGET ${triplet})
set(CMAKE_C_FLAGS_INIT "--target=${CMAKE_C_COMPILER_TARGET} -fms-compatibility")
set(CMAKE_C_LIBRARY_ARCHITECTURE "${CMAKE_VS_PLATFORM_NAME}")
set(CMAKE_CXX_COMPILER_TARGET ${triplet})
set(CMAKE_CXX_FLAGS_INIT "--target=${CMAKE_CXX_COMPILER_TARGET} -fms-compatibility")
set(CMAKE_CXX_LIBRARY_ARCHITECTURE "${CMAKE_VS_PLATFORM_NAME}")

set(CMAKE_INCLUDE_SYSTEM_FLAG_C "-imsvc")
set(CMAKE_INCLUDE_SYSTEM_FLAG_CXX "-imsvc")

set(CMAKE_EXE_LINKER_FLAGS_INIT "/manifest:no")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "/manifest:no")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "/manifest:no")

set(CMAKE_USER_MAKE_RULES_OVERRIDE "$ENV{TOOLCHAIN_PREFIX}/CMakeCompileRules.cmake")

include_directories(
    SYSTEM "$ENV{VCToolsInstallDir}include" "$ENV{WindowsSdkDir}Include/$ENV{WindowsSDKVersion}ucrt"
    "$ENV{WindowsSdkDir}Include/$ENV{WindowsSDKVersion}shared" "$ENV{WindowsSdkDir}Include/$ENV{WindowsSDKVersion}um"
    "$ENV{WindowsSdkDir}Include/$ENV{WindowsSDKVersion}cppwinrt")

build_vfs_overlay("$ENV{WindowsSdkDir}Include")
process_library_path("$ENV{VCToolsInstallDir}lib/${CMAKE_VS_PLATFORM_NAME}")
process_library_path("$ENV{WindowsSdkDir}Lib/$ENV{WindowsSDKLibVersion}ucrt/${CMAKE_VS_PLATFORM_NAME}")
process_library_path("$ENV{WindowsSdkDir}Lib/$ENV{WindowsSDKLibVersion}um/${CMAKE_VS_PLATFORM_NAME}")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
