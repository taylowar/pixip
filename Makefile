# Makefile for pixip

CXX=clang++
MINGW_CXX=x86_64-w64-mingw32-g++

.PHONY: clean linux_source_build_libde265 linux_source_build_libheif

# --- libde265 -------------------------------------------------------------------------------------

# Expand the library tarball (linux)
./thirdparty/libde265-1.0.16-linux: ./thirdparty/libde265-1.0.16.tar.gz
	@cd ./thirdparty; \
	tar -xvf libde265-1.0.16.tar.gz; \
	mv libde265-1.0.16 libde265-1.0.16-linux; \
	echo "'./thirdparty/libde265-1.0.16-linux' extracted"; \

# Build libde265 (linux)
./thirdparty/libde265-1.0.16-linux/build/dist/libde265: ./thirdparty/libde265-1.0.16-linux
	# libde265 build directory
	@mkdir -p ./thirdparty/libde265-1.0.16-linux/build
	# CMake (linux)
	@cd ./thirdparty/libde265-1.0.16-linux/build; \
	cmake \
		-DCMAKE_BUILD_TYPE=release \
		-DCMAKE_INSTALL_PREFIX=./install \
		-DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
		..; \
	cmake --build . -- -j 8; \
	cmake --install . --prefix ./dist/libde265

linux_source_build_libde265: ./thirdparty/libde265-1.0.16-linux/build/dist/libde265
	@mkdir -p "./build"
	@mkdir -p "./build/linux"
	@if [ ! -d "./build/linux/libde265" ]; then \
		mv ./thirdparty/libde265-1.0.16-linux/build/dist/libde265 ./build/linux; \
		echo "Moved 'libde265' to './build/linux'"; \
	fi

# Expand the library tarball (windows/MinGW)
./thirdparty/libde265-1.0.16-mingw: ./thirdparty/libde265-1.0.16.tar.gz
	@ cd ./thirdparty; \
	tar -xvf libde265-1.0.16.tar.gz
	@mv ./thirdparty/libde265-1.0.16 ./thirdparty/libde265-1.0.16-mingw
	echo "'./thirdparty/libde265-1.0.16-mingw' extracted"

# Build libde265 (windows/MinGW)
./thirdparty/libde265-1.0.16-mingw/build/dist/libde265: ./thirdparty/libde265-1.0.16-mingw
	# libde265 build directory
	@mkdir -p ./thirdparty/libde265-1.0.16-mingw/build
	# copy mingw cmake toolchain
	@cp ./mingw-libde265-toolchain.cmake ./thirdparty/libde265-1.0.16-mingw/
	# CMake (mingw)
	@cd ./thirdparty/libde265-1.0.16-mingw/build; \
	cmake \
		-DCMAKE_TOOLCHAIN_FILE=mingw-libde265-toolchain.cmake \
		-DCMAKE_BUILD_TYPE=release \
		-DCMAKE_INSTALL_PREFIX=./install \
		-DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
		..; \
	cmake --build . -- -j 8; \
	cmake --install . --prefix ./dist/libde265

mingw_source_build_libde265: ./thirdparty/libde265-1.0.16-mingw/build/dist/libde265
	@mkdir -p "./build"
	@mkdir -p "./build/windows"
	@if [ ! -d "./build/windows/libde265" ]; then \
		mv ./thirdparty/libde265-1.0.16-mingw/build/dist/libde265 ./build/windows; \
		echo "Moved 'libde265' to './build/windows'"; \
	fi

# --- end libde265 ---------------------------------------------------------------------------------

# --- libheif --------------------------------------------------------------------------------------

# Expand the library tarball (linux)
./thirdparty/libheif-1.20.2-linux: ./thirdparty/libheif-1.20.2.tar.gz
	@cd ./thirdparty; \
	tar -xvf libheif-1.20.2.tar.gz; \
	mv libheif-1.20.2 libheif-1.20.2-linux; \
	echo "'./thirdparty/libheif-1.20.2-linux' extracted"; \

# Build libheif (linux)
./thirdparty/libheif-1.20.2-linux/build/dist/libheif: linux_source_build_libde265 ./thirdparty/libheif-1.20.2-linux
	# libde265 build directory
	@mkdir -p ./thirdparty/libheif-1.20.2-linux/build
	# CMake (linux)
	@cd ./thirdparty/libheif-1.20.2-linux/build; \
	cmake \
	cmake \
		-DCMAKE_BUILD_TYPE=release \
		-DCMAKE_INSTALL_PREFIX=./install \
		-DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
		-DLIBDE265_INCLUDE_DIR=/home/tilc/dev/programming/c/pixip/build/linux/libde265/include \
		-DLIBDE265_LIBRARY=/home/tilc/dev/programming/c/pixip/build/linux/libde265/lib/libde265.so \
		..; \
	cmake --build . -- -j 8; \
	cmake --install . --prefix ./dist/libheif
	# Making NeoVim see the build library
	ln -sf ./thirdparty/libheif-1.20.2-linux/build/compile_commands.json ./compile_commands.json

linux_source_build_libheif: ./thirdparty/libheif-1.20.2-linux/build/dist/libheif
	@mkdir -p "./build"
	@mkdir -p "./build/linux"
	@if [ ! -d "./build/linux/libheif" ]; then \
		mv ./thirdparty/libheif-1.20.2-linux/build/dist/libheif ./build/linux; \
		echo "Moved 'libheif' to './build/linux'"; \
	fi

# Expand the library tarball (windows/MinGW)
./thirdparty/libheif-1.20.2-mingw: ./thirdparty/libheif-1.20.2.tar.gz
	@cd ./thirdparty; \
	tar -xvf libheif-1.20.2.tar.gz; \
	mv libheif-1.20.2 libheif-1.20.2-mingw; \
	echo "'./thirdparty/libheif-1.20.2-mingw' extracted"; \

# Build libheif (windows/MinGW)
./thirdparty/libheif-1.20.2-mingw/build/dist/libheif: mingw_source_build_libde265 ./thirdparty/libheif-1.20.2-mingw
	# libheif build directory
	@mkdir -p ./thirdparty/libheif-1.20.2-mingw/build
	# copy mingw cmake toolchain
	@cp ./mingw-libheif-toolchain.cmake ./thirdparty/libheif-1.20.2-mingw/
	# CMake (mingw)
	@cd ./thirdparty/libheif-1.20.2-mingw/build; \
	cmake \
		-DCMAKE_TOOLCHAIN_FILE=mingw-libheif-toolchain.cmake \
		-DCMAKE_BUILD_TYPE=release \
		-DCMAKE_INSTALL_PREFIX=./install \
		-DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
		-DLIBDE265_INCLUDE_DIR=/home/tilc/dev/programming/c/pixip/build/windows/libde265/include \
		-DLIBDE265_LIBRARY=/home/tilc/dev/programming/c/pixip/build/windows/libde265/lib/libde265.dll.a \
		..; \
	cmake --build . -- -j 8; \
	cmake --install . --prefix ./dist/libheif

mingw_source_build_libheif: ./thirdparty/libheif-1.20.2-mingw/build/dist/libheif
	@mkdir -p "./build"
	@mkdir -p "./build/windows"
	@if [ ! -d "./build/windows/libheif" ]; then \
		mv ./thirdparty/libheif-1.20.2-mingw/build/dist/libheif ./build/windows; \
		echo "Moved 'libheif' to './build/windows'"; \
	fi

# --- end libheif ----------------------------------------------------------------------------------

# --- libjpeg --------------------------------------------------------------------------------------

# Expand the library tarball (linux)
./thirdparty/libjpeg-turbo-3.1.2-linux: ./thirdparty/libjpeg-turbo-3.1.2.tar.gz
	@cd ./thirdparty; \
	tar -xvf libjpeg-turbo-3.1.2.tar.gz; \
	mv libjpeg-turbo-3.1.2 libjpeg-turbo-3.1.2-linux; \
	echo "'./thirdparty/libjpeg-turbo-3.1.2-linux' extracted"; \

# Build libjpeg (linux)
./thirdparty/libjpeg-turbo-3.1.2-linux/build/dist/libjpeg: ./thirdparty/libjpeg-turbo-3.1.2-linux
	# libde265 build directory
	@mkdir -p ./thirdparty/libjpeg-turbo-3.1.2-linux/build
	# CMake (linux)
	@cd ./thirdparty/libjpeg-turbo-3.1.2-linux/build; \
	cmake \
	cmake \
		-DCMAKE_BUILD_TYPE=release \
		-DCMAKE_INSTALL_PREFIX=./install \
		-DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
		..; \
	cmake --build . -- -j 8; \
	cmake --install . --prefix ./dist/libjpeg

linux_source_build_libjpeg: ./thirdparty/libjpeg-turbo-3.1.2-linux/build/dist/libjpeg
	@mkdir -p "./build"
	@mkdir -p "./build/linux"
	@if [ ! -d "./build/linux/libjpeg" ]; then \
		mv ./thirdparty/libjpeg-turbo-3.1.2-linux/build/dist/libjpeg ./build/linux; \
		echo "Moved 'libjpeg' to './build/linux'"; \
	fi
	
# Expand the library tarball (windows/MinGW)
./thirdparty/libjpeg-turbo-3.1.2-mingw: ./thirdparty/libjpeg-turbo-3.1.2.tar.gz
	@cd ./thirdparty; \
	tar -xvf libjpeg-turbo-3.1.2.tar.gz; \
	mv libjpeg-turbo-3.1.2 libjpeg-turbo-3.1.2-mingw; \
	echo "'./thirdparty/libjpeg-turbo-3.1.2-mingw' extracted"; \

# Build libjpeg (windows/MinGW)
./thirdparty/libjpeg-turbo-3.1.2-mingw/build/dist/libjpeg: mingw_source_build_libde265 ./thirdparty/libjpeg-turbo-3.1.2-mingw
	# libjpeg build directory
	@mkdir -p ./thirdparty/libjpeg-turbo-3.1.2-mingw/build
	# copy mingw cmake toolchain
	@cp ./mingw-libjpeg-toolchain.cmake ./thirdparty/libjpeg-turbo-3.1.2-mingw/
	# CMake (mingw)
	@cd ./thirdparty/libjpeg-turbo-3.1.2-mingw/build; \
	cmake \
		-DCMAKE_TOOLCHAIN_FILE=mingw-libjpeg-toolchain.cmake \
		-DCMAKE_BUILD_TYPE=release \
		-DCMAKE_INSTALL_PREFIX=./install \
		-DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
		..; \
	cmake --build . -- -j 8; \
	cmake --install . --prefix ./dist/libjpeg

mingw_source_build_libjpeg: ./thirdparty/libjpeg-turbo-3.1.2-mingw/build/dist/libjpeg
	@mkdir -p "./build"
	@mkdir -p "./build/windows"
	@if [ ! -d "./build/windows/libjpeg" ]; then \
		mv ./thirdparty/libjpeg-turbo-3.1.2-mingw/build/dist/libjpeg ./build/windows; \
		echo "Moved 'libjpeg' to './build/windows'"; \
	fi

# --- end libjpeg ----------------------------------------------------------------------------------

# --- linux builder --------------------------------------------------------------------------------
LINUX_LIBDE_DIR := ./build/linux/libde265
LINUX_LIBDE_INCLUDES := -I$(LINUX_LIBDE_DIR)/include
LINUX_LIBDE_LIBS := -L$(LINUX_LIBDE_DIR)/lib -Wl, -rpath $(LINUX_LIBDE_DIR)/lib

LINUX_LIBHEIF_DIR := ./build/linux/libheif
LINUX_LIBHEIF_INCLUDES := -I$(LINUX_LIBHEIF_DIR)/include
LINUX_LIBHEIF_LIBS := -L$(LINUX_LIBHEIF_DIR)/lib  -Wl, -rpath $(LINUX_LIBHEIF_DIR)/lib

LINUX_LIBJPEG_DIR := ./build/linux/libjpeg
LINUX_LIBJPEG_INCLUDES := -I$(LINUX_LIBJPEG_DIR)/include
LINUX_LIBJPEG_LIBS := -L$(LINUX_LIBJPEG_DIR)/lib  -Wl, -rpath $(LINUX_LIBJPEG_DIR)/lib

LINUX_LIBS=$(LINUX_LIBDE_LIBS) $(LINUX_LIBHEIF_LIBS) $(LINUX_LIBJPEG_LIBS) -lde265 -lheif -ljpeg
LINUX_INCLUDES=$(LINUX_LIBDE_INCLUDES) $(LINUX_LIBHEIF_INCLUDES)
LINUX_CFLAGS := -Wall -Wextra

linux-build: linux_source_build_libheif linux_source_build_libjpeg linux_source_build_libjpeg ./src/main.cpp
	@mkdir -p "./dist"
	@mkdir -p "./dist/linux"
	$(CXX) $(LINUX_CFLAGS) -o ./dist/linux/pixip src/main.cpp $(LINUX_INCLUDES) $(LINUX_LIBS)
	@cp ./build/linux/libde265/lib/libde265.so ./dist/linux
	@cp ./build/linux/libheif/lib/libheif.so ./dist/linux
	@echo "DONE"

# --- end linux builder ----------------------------------------------------------------------------

# --- windows builder ------------------------------------------------------------------------------

MINGW_LIBDE_DIR := ./build/windows/libde265
MINGW_LIBDE_INCLUDES := -I$(MINGW_LIBDE_DIR)/include
MINGW_LIBDE_LIBS := -L$(MINGW_LIBDE_DIR)/lib

MINGW_LIBHEIF_DIR := ./build/windows/libheif
MINGW_LIBHEIF_INCLUDES := -I$(MINGW_LIBHEIF_DIR)/include
MINGW_LIBHEIF_LIBS := -L$(MINGW_LIBHEIF_DIR)/lib

# TODO: libjpeg

MINGW_LIBS=$(MINGW_LIBDE_LIBS) $(MINGW_LIBHEIF_LIBS) -lde265 -lheif -lm
MINGW_INCLUDES=$(MINGW_LIBDE_INCLUDES) $(MINGW_LIBHEIF_INCLUDES)
MINGW_CFLAGS := -Wall -Wextra

windows-build: mingw_source_build_libheif src/main.cpp
	@mkdir -p "./dist"
	@mkdir -p "./dist/windows"
	$(MINGW_CXX) $(MINGW_CFLAGS) -o ./dist/windows/pixip src/main.cpp $(MINGW_INCLUDES) $(MINGW_LIBS)
	@cp ./build/windows/libde265/bin/libde265.dll ./dist/windows
	@cp ./build/windows/libheif/bin/libheif.dll ./dist/windows
	@cp ./thirdparty/mingw/bin/libgcc_s_seh-1.dll ./dist/windows
	@cp ./thirdparty/mingw/bin/libstdc++-6.dll ./dist/windows
	@echo "DONE"

# --- end windows builder --------------------------------------------------------------------------

clean:
	@rm -rf ./build
	@echo "Removed './build' directory"
	@rm -rf ./thirdparty/libde265-1.0.16-linux
	@echo "Removed './thirdparty/libde265-1.0.16-linux' directory"
	@rm -rf ./thirdparty/libde265-1.0.16-mingw
	@echo "Removed './thirdparty/libde265-1.0.16-mingw' directory"
	@rm -rf ./thirdparty/libheif-1.20.2-linux
	@echo "Removed './thirdparty/libheif-1.20.2-linux' directory"
	@rm -rf ./thirdparty/libheif-1.20.2-mingw
	@echo "Removed './thirdparty/libheif-1.20.2-mingw' directory"
	@rm -rf ./thirdparty/libjpeg-turbo-3.1.2-linux
	@echo "Removed './thirdparty/libjpeg-turbo-3.1.2-linux' directory"
	@rm -rf ./thirdparty/libjpeg-turbo-3.1.2-mingw
	@echo "Removed './thirdparty/libjpeg-turbo-3.1.2-mingw' directory"

