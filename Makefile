# Top-level Makefile for pixip
# Cross-platform Linux / Windows builds with third-party libraries

# -----------------------------
# Variables
# -----------------------------
CXX := clang++
MINGW_CXX := x86_64-w64-mingw32-g++

CURDIR := $(shell pwd)
TP := $(CURDIR)/thirdparty
BUILD := $(CURDIR)/build

# Library prefixes
LINUX_LIBDE_PREFIX := $(BUILD)/linux/libde265
LINUX_LIBHEIF_PREFIX := $(BUILD)/linux/libheif
LINUX_LIBJPEG_PREFIX := $(BUILD)/linux/libjpeg
LINUX_LIBDMON_PREFIX := $(BUILD)/linux/libdmon

WIN32_LIBDE_PREFIX := $(BUILD)/windows/libde265
WIN32_LIBHEIF_PREFIX := $(BUILD)/windows/libheif
WIN32_LIBJPEG_PREFIX := $(BUILD)/windows/libjpeg
WIN32_LIBDMON_PREFIX := $(BUILD)/windows/libdmon

# Source file
SRC_LINUX := src/main.cpp
SRC_WIN32 := src/main_win32.cpp

# Number of parallel build jobs
JOBS := $(shell nproc)

# -----------------------------
# Phony targets
# -----------------------------
.PHONY: all linux windows clean \
        linux_source_build_libde265 mingw_source_build_libde265 \
        linux_source_build_libheif mingw_source_build_libheif \
        linux_source_build_libjpeg mingw_source_build_libjpeg \
        clean-libde265 clean-libheif clean-libjpeg

# -----------------------------
# All
# -----------------------------
all: linux windows

# -----------------------------
# Linux build
# -----------------------------
linux: linux_source_build_libde265 linux_source_build_libheif linux_source_build_libjpeg linux_source_build_libdmon
	@echo "Building pixip Linux executable..."
	@mkdir -p $(CURDIR)/dist/linux
	@mkdir -p $(CURDIR)/dist/linux/lib
	$(CXX) -Wall -Wextra $(SRC_LINUX) \
		-I$(LINUX_LIBDE_PREFIX)/include \
		-I$(LINUX_LIBHEIF_PREFIX)/include \
		-I$(LINUX_LIBJPEG_PREFIX)/include \
		-I$(LINUX_LIBDMON_PREFIX)/include \
		-L$(LINUX_LIBDE_PREFIX)/lib \
		-L$(LINUX_LIBHEIF_PREFIX)/lib \
		-L$(LINUX_LIBJPEG_PREFIX)/lib \
		-L$(LINUX_LIBDMON_PREFIX)/lib \
		-Wl,-rpath,'$$ORIGIN/lib' \
		-lde265 -lheif -ljpeg -ldmon \
		-o $(CURDIR)/dist/linux/pixip
	@cp $(LINUX_LIBDE_PREFIX)/lib/libde265.so $(CURDIR)/dist/linux/lib
	@cp $(LINUX_LIBHEIF_PREFIX)/lib/libheif.so $(CURDIR)/dist/linux/lib/libheif.so.1
	@cp $(LINUX_LIBJPEG_PREFIX)/lib/libjpeg.so $(CURDIR)/dist/linux/lib/libjpeg.so.62
	@cp $(LINUX_LIBDMON_PREFIX)/lib/libdmon.so $(CURDIR)/dist/linux/lib
	@echo "DONE: Linux build complete"

# -----------------------------
# Windows / MinGW build
# -----------------------------
windows: mingw_source_build_libde265 mingw_source_build_libheif mingw_source_build_libjpeg mingw_source_build_libdmon
	@echo "Building pixip Windows executable..."
	@mkdir -p $(CURDIR)/dist/windows
	$(MINGW_CXX) -Wall -Wextra $(SRC_WIN32) \
		-I$(WIN32_LIBDE_PREFIX)/include \
		-I$(WIN32_LIBHEIF_PREFIX)/include \
		-I$(WIN32_LIBJPEG_PREFIX)/include \
		-L$(WIN32_LIBDE_PREFIX)/lib \
		-L$(WIN32_LIBHEIF_PREFIX)/lib \
		-L$(WIN32_LIBJPEG_PREFIX)/lib \
		-L$(WIN32_LIBDMON_PREFIX)/lib \
		-lde265 -lheif -ljpeg -lm -ldmon \
		-o $(CURDIR)/dist/windows/pixip.exe
	@cp $(WIN32_LIBDE_PREFIX)/bin/*.dll $(CURDIR)/dist/windows
	@cp $(WIN32_LIBHEIF_PREFIX)/bin/*.dll $(CURDIR)/dist/windows
	@cp $(WIN32_LIBJPEG_PREFIX)/bin/*.dll $(CURDIR)/dist/windows
	@cp $(WIN32_LIBDMON_PREFIX)/bin/*.dll $(CURDIR)/dist/windows
	@echo "DONE: Windows build complete"

# -----------------------------
# Include third-party builds
# -----------------------------

# libde265
include mk/libde265.mk

# libheif (depends on libde265)
include mk/libheif.mk

# libjpeg (optional)
include mk/libjpeg.mk

# libdmon 
include mk/libdmon.mk

probe:
	$(MINGW_CXX) -fPIC -shared -Wall -Wextra -o ./bin/windows/libdmon.dll ./src/dmon_win32.cpp
	$(MINGW_CXX) -Wall -Wextra -o ./bin/windows/main_w32.exe ./src/main_win32.cpp -L ./bin/windows -ldmon


# -----------------------------
# Clean
# -----------------------------
clean: 
	@rm -rf $(BUILD) $(CURDIR)/dist
	@echo "Cleaned all build artifacts"

