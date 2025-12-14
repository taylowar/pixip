# Makefile for ICS

main: prepare_build_directory src/main.c
	$(CC) -Wall -Wextra -o ./build/main src/main.c


# --------------------------------------------------------------------------------------------------

./thirdparty/libde265-1.0.16-linux: ./thirdparty/libde265-1.0.16.tar.gz
	cd ./thirdparty; \
	tar -xvf libde265-1.0.16.tar.gz; \
	mv libde265-1.0.16 libde265-1.0.16-linux; \
	echo "'./thirdparty/libde265-1.0.16-linux' extracted"; \

./thirdparty/libde265-1.0.16-linux/build/dist/libde265: ./thirdparty/libde265-1.0.16-linux
	# Create build directory \
	cd ./thirdparty/libde265-1.0.16-linux; \
	mkdir build; \
	cd build;
	# CMake \
	cd ./thirdparty/libde265-1.0.16-linux/build; \
	cmake \
		-DCMAKE_BUILD_TYPE=release \
		-DCMAKE_INSTALL_PREFIX=./install \
		-DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
		..; \
	cmake --build . -- -j 8; \
	cmake --install . --prefix ./dist/libde265

build: ./thirdparty/libde265-1.0.16-linux/build/dist/libde265
	@mkdir -p "./build"
	@if [ ! -d "./build/libde265" ]; then \
		mv ./thirdparty/libde265-1.0.16-linux/build/dist/libde265 ./build; \
		echo "Moved 'libde265' to './build'"; \
	fi
	@echo "DONE"


# --------------------------------------------------------------------------------------------------
.PHONY:
prepare_build_directory:
	@if [ ! ! -d "./build" ]; then \
		mkdir ./build; \
	fi 
