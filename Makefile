# Makefile for ICS

main: prepare_build_directory src/main.c
	$(CC) -Wall -Wextra -o ./build/main src/main.c


# --------------------------------------------------------------------------------------------------

.PHONY:
.SILENT:
linux_source_build_libde265: thirdparty/libde265-1.0.16.tar.gz
	if [ -d ./thirdparty/linux/libde265-1.0.16/build/dist/libde265 ]; then \
		echo "Nothing to do :: libde265 (linux) already to build"; \
	else \
		# Expand build files (linux) \
		if [ ! -d ./thirdparty/linux/libde265-1.0.16 ]; then \
			mkdir ./thirdparty/linux; \
			cd ./thirdparty; \
			tar -xvf libde265-1.0.16.tar.gz; \
			mv libde265-1.0.16 ./linux; \
		else \
			echo "'./thirdparty/linux/libde265-1.0.16' is already extracted"; \
		fi; \
		# Create build directory \
		cd ./thirdparty/linux/libde265-1.0.16; \
		mkdir build; \
		cd build; \
		# CMake \
		cd ./thirdparty/linux/libde265-1.0.16/build;\
		cmake \
			-DCMAKE_BUILD_TYPE=release \
			-DCMAKE_INSTALL_PREFIX=./install \
			-DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
			..; \
		cmake --build . -- -j 8; \
		cmake --install . --prefix ./dist/libde265; \
	fi


# --------------------------------------------------------------------------------------------------
.PHONY:
prepare_build_directory:
	@if [ ! ! -d "./build" ]; then \
		mkdir ./build; \
	fi 
