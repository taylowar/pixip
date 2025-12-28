# mingw-libde265-toolchain.cmake
# Toolchain for cross-compiling libde265 (dynamic) for Windows using MinGW-w64

# Target system
set(CMAKE_SYSTEM_NAME Windows)

# Cross compiler
set(CMAKE_C_COMPILER   x86_64-w64-mingw32-gcc)
set(CMAKE_CXX_COMPILER x86_64-w64-mingw32-g++)

# Force shared linking 
set(BUILD_SHARED_LIBS ON CACHE BOOL "Build shared libraries (.dll)")

# Don't try to run compiled executables
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# Endianness
set(TEST_BIG_ENDIAN FALSE)
set(WORDS_BIGENDIAN FALSE)

# Prefix for installation
set(CMAKE_INSTALL_PREFIX ${CMAKE_CURRENT_SOURCE_DIR}/install)

# Optional: force PIC for static lib (recommended)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Set Windows defines
add_definitions(-DWIN32 -D_WINDOWS)

# Optional: If you want pkg-config to work for libheif later
set(ENV{PKG_CONFIG_PATH} "${CMAKE_INSTALL_PREFIX}/lib/pkgconfig")

# TODO: do I need this?
# Optional: add CMake flags for static linking of CRT
set(CMAKE_C_FLAGS_RELEASE "-O2 -static")
set(CMAKE_CXX_FLAGS_RELEASE "-O2 -static")

# Optional: Disable examples/tests if desired
set(BUILD_EXAMPLES OFF CACHE BOOL "Do not build examples")
set(BUILD_TESTS OFF CACHE BOOL "Do not build tests")
