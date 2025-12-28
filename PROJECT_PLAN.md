# PROJECT PLAN (ICS)

## Libraries
* Image Fromat Libraries  
    * [x] HVEC - H.265 High Efficiency Video Coding
        - `libde265-1.0.16.tar.gz`
    * [ ] ISO/IEC 23008-12:2017 HEIF and AVIF file format decoder and encoder
        - `libheif-1.20.2.tar.gz`
    * [ ] JPEG image codec (for JPEG image compression and decompression)
        - `libjpeg-turbo-3.1.2.tar.gz`
* [ ] MinGW dependencies
    * Runtime libraries neede by GCC
    * Runtime support library needed for `Structured Exception Handling` (**SEH**) for C++
        - `mingw/libgcc_s_seh-1.dll`
    * Standard C++ library providing implementations of C++
        * `mingw/libstdc++-6.dll`
    * [ ] **NOTE**: Look into static linking of this libraries 
        - `https://www.codestudy.net/blog/mingw-exe-requires-a-few-gcc-dll-s-regardless-of-the-code/`
* STB libs
    * STB libraries useful for manipulating images
    * [ ] `stb_image.h`
    * [ ] `stb_image_resize2.h`
    * [ ] `stb_image_write.h`

## BUILD SYSTEM

* Use `Makefile` for the build system 
* Implement targets for each step of the build process
* Include *Linux to Windows* cross-compilation using the `MinGW` compiler
* Expected targets:
    - [x] `linux_source_build_libde265`
    - [x] `mingw_source_build_libde265`
    - [ ] `linux_source_build_libheif` (depends on `linux_source_build_libde265`)
    - [ ] `mingw_source_build_libheif` (depends on `mingw_source_build_libde265`)
    - [ ] `linux_source_build_libjpeg` 
    - [ ] `mingw_source_build_libjpeg`
    - [ ] `clean`
        - removes all unzipped library sources
        - removes all build libraries
        - removes all build targets
    - [ ] `linux_build`
        - This is a single target which builds both all the libraries and the final application
    - [ ] `mingw_build`
        - This is a single target which builds both all the libraries and the final application

# Directory monitor library
* [ ] `dmon.h`
* Monitoring changes inside a directory
* Event callbacks
    - For example when a file is created, deleted, modified, etc.
    - Get access to the path of the new file and do something
* We use `inotify.h` for the linux implementation and `ReadDirectoryChangesW` for the windows implementation
    - look at `../dir-watcher`
