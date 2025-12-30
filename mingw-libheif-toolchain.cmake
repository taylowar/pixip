# mingw-libde265-toolchain.cmake
# Toolchain for cross-compiling libheif (dll) for Windows using MinGW-w64

# ------------------------------
# 1. Target system and compilers
# ------------------------------
set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_VERSION 1)  # Minimal version, can be ignored for cross-compile

# Specify cross compilers
set(CMAKE_C_COMPILER x86_64-w64-mingw32-gcc)
set(CMAKE_CXX_COMPILER x86_64-w64-mingw32-g++)

# ------------------------------
# 2. Endianness
# ------------------------------
# libheif expects little-endian
set(TEST_BIG_ENDIAN FALSE CACHE INTERNAL "")
set(WORDS_BIGENDIAN FALSE CACHE INTERNAL "")

find_library(DE265_LIBRARY de265 PATHS /home/tilc/dev/programming/c/pixip/build/windows/libde265/lib)
if(TARGET heif-info)
    target_link_libraries(heif-info PRIVATE ${DE265_LIBRARY})
endif()
if(TARGET heif-enc)
    target_link_libraries(heif-enc PRIVATE ${DE265_LIBRARY})
endif()
# ------------------------------
# 3. Build options
# ------------------------------
# Enable shared libraries if desired
option(BUILD_SHARED_LIBS "Build shared libraries" ON)

# Disable optional examples/tests
option(ENABLE_EXAMPLES "Build examples" OFF)
option(ENABLE_TESTS "Build tests" OFF)

# libheif-specific options
set(HEIF_ENABLE_EXAMPLES OFF CACHE INTERNAL "")
set(HEIF_ENABLE_TESTS OFF CACHE INTERNAL "")
set(HEIF_ENABLE_CAPI ON CACHE INTERNAL "")
set(HEIF_ENABLE_PLUGINS ON CACHE INTERNAL "")

# Enable HEVC (libde265) support
option(BUILD_HEVC "Enable HEVC support (libde265/x265)" ON)

# ------------------------------
# 4. Optional dependency paths
# ------------------------------
# If you have cross-compiled libde265, set the include/lib paths here
set(LIBDE265_INCLUDE_DIRS "/home/tilc/dev/programming/c/pixip/build/windows/libde265/include" CACHE PATH "Path to libde265 headers")
set(LIBDE265_LIBRARIES "/home/tilc/dev/programming/c/pixip/build/windows/libde265/lib/libde265.dll.a" CACHE FILEPATH "Path to libde265 library")
set(LIBDE265_PROCESS_INCLUDES "/home/tilc/dev/programming/c/pixip/build/windows/libde265/include")
set(LIBDE265_PROCESS_LIBS "/home/tilc/dev/programming/c/pixip/build/windows/libde265/lib/libde265.dll.a")

# If using other optional dependencies, add them here, e.g. libjpeg, libpng, x265, etc.
# set(JPEG_INCLUDE_DIR "C:/mingw-w64/jpeg/include")
# set(JPEG_LIBRARY "C:/mingw-w64/jpeg/lib/jpeg.lib")

# ------------------------------
# 5. CMake module path for FindLIBDE265.cmake
# ------------------------------
# Ensure CMake can locate your custom FindLIBDE265.cmake
set(CMAKE_MODULE_PATH "/home/tilc/dev/programming/c/pixip/thirdparty/libde265-1.0.16-mingw/cmake/modules" ${CMAKE_MODULE_PATH})
