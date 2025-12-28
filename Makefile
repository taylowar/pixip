# Makefile for pixip

CXX=clang++
MINGW_CXX=x86_64-w64-mingw32-gcc

.PHONY: clean

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


LD_LIBDE_FLAGS:=-L./build/linux/libde265/lib -Wl,-rpath,'$$ORIGIN/./libde265/lib'
LD_FLAGS:=$(LD_LIBDE_FLAGS)
LD_LIBS:=-lde265

linux-build: ./thirdparty/libde265-1.0.16-linux/build/dist/libde265 ./src/main.c
	@mkdir -p "./build"
	@mkdir -p "./build/linux"
	@if [ ! -d "./build/linux/libde265" ]; then \
		mv ./thirdparty/libde265-1.0.16-linux/build/dist/libde265 ./build/linux; \
		echo "Moved 'libde265' to './build/linux'"; \
	fi
	$(CXX) -Wall -Wextra -o ./build/linux/main src/main.c $(LD_FLAGS) $(LD_LIBS)
	@echo "DONE"

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

W64_LD_LIBDE_FLAGS:=-L./build/windows/libde265/lib -Wl,-rpath,'$$ORIGIN/./libde265/lib'
W64_LD_FLAGS:=$(W64_LD_LIBDE_FLAGS)
W64_LD_LIBS:=-lde265

windows-build: ./thirdparty/libde265-1.0.16-mingw/build/dist/libde265
	@mkdir -p "./build"
	@mkdir -p "./build/windows"
	@if [ ! -d "./build/windows/libde265" ]; then \
		mv ./thirdparty/libde265-1.0.16-mingw/build/dist/libde265 ./build/windows; \
		echo "Moved 'libde265' to './build/windows'"; \
	fi
	$(MINGW_CXX) -Wall -Wextra -o ./build/windows/main src/main.c $(W64_LD_FLAGS) $(W64_LD_LIBS)
	@echo "DONE"

# --- end libde265 ---------------------------------------------------------------------------------

clean:
	@rm -rf ./build
	@echo "Removed './build' directory"
	@rm -rf ./thirdparty/libde265-1.0.16-linux
	@echo "Removed './thirdparty/libde265-1.0.16-linux' directory"
	@rm -rf ./thirdparty/libde265-1.0.16-mingw
	@echo "Removed './thirdparty/libde265-1.0.16-mingw' directory"

