# libimgdec.mk - builds libimgdec for Linux and MinGW

# -----------------------------
# Dependencies
# -----------------------------

LINUX_LIBDE_PREFIX := $(BUILD)/linux/libde265
LINUX_LIBHEIF_PREFIX := $(BUILD)/linux/libheif

WIN32_LIBDE_PREFIX := $(BUILD)/windows/libde265
WIN32_LIBHEIF_PREFIX := $(BUILD)/windows/libheif


# libde265
include mk/libde265.mk

# libheif (depends on libde265)
include mk/libheif.mk

# -----------------------------
# Variables
# -----------------------------
LIBIMGDEC_LINUX_SRC := $(CURDIR)/src/img_dec/img_dec_posix.cpp
LIBIMGDEC_WIN32_SRC := $(CURDIR)/src/img_dec/img_dec_win32.cpp
BUILD := $(CURDIR)/build

LIBIMGDEC_LINUX_PREFIX := $(BUILD)/linux/libimgdec
LIBIMGDEC_WIN32_PREFIX   := $(BUILD)/windows/libimgdec

# -----------------------------
# Phony targets
# -----------------------------
.PHONY: linux_source_build_libimgdec mingw_source_build_libimgdec

# -----------------------------
# Linux build
# -----------------------------
linux_source_build_libimgdec: $(LIBIMGDEC_LINUX_SRC) linux_source_build_libheif
	@echo "Building libimgdec for Linux..."
	@mkdir -p $(BUILD)/linux
	@mkdir -p $(LIBIMGDEC_LINUX_PREFIX)/lib
	$(CXX) -fPIC -Wall -Wextra -shared \
		-I$(LINUX_LIBDE_PREFIX)/include \
		-I$(LINUX_LIBHEIF_PREFIX)/include \
		-L$(LINUX_LIBDE_PREFIX)/lib \
		-L$(LINUX_LIBHEIF_PREFIX)/lib \
		-lde265 -lheif \
		-o $(LIBIMGDEC_LINUX_PREFIX)/lib/libimgdec.so $(LIBIMGDEC_LINUX_SRC)
	@mkdir -p $(LIBIMGDEC_LINUX_PREFIX)/include
	@cp $(CURDIR)/src/dmon/dmon.h $(LIBIMGDEC_LINUX_PREFIX)/include

# -----------------------------
# MinGW build
# -----------------------------
mingw_source_build_libimgdec: $(LIBIMGDEC_WIN32_SRC) mingw_source_build_libheif
	@echo "Building libimgdec for MinGW..."
	@mkdir -p $(BUILD)/windows
	@mkdir -p $(LIBIMGDEC_WIN32_PREFIX)/bin
	$(MINGW_CXX) -fPIC -shared -Wall -Wextra \
		-I$(WIN32_LIBDE_PREFIX)/include \
		-I$(WIN32_LIBHEIF_PREFIX)/include \
		-L$(WIN32_LIBDE_PREFIX)/bin \
		-L$(WIN32_LIBHEIF_PREFIX)/bin \
		-lde265 -lheif \
		-o $(LIBIMGDEC_WIN32_PREFIX)/bin/libimgdec.dll $(LIBIMGDEC_WIN32_SRC)
	@mkdir -p $(LIBIMGDEC_WIN32_PREFIX)/lib
	@cp $(LIBIMGDEC_WIN32_PREFIX)/bin/libimgdec.dll $(LIBIMGDEC_WIN32_PREFIX)/lib
	@mkdir -p $(LIBIMGDEC_WIN32_PREFIX)/include
	@cp $(CURDIR)/src/dmon/dmon.h $(LIBIMGDEC_WIN32_PREFIX)/include
