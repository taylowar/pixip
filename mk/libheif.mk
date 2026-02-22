# libheif.mk - builds libheif for Linux and MinGW
# Depends on libde265

# -----------------------------
# Variables
# -----------------------------
LIBHEIF_VERSION := 1.20.2
TP := $(CURDIR)/thirdparty
BUILD := $(CURDIR)/build

LIBHEIF_LINUX_PREFIX := $(BUILD)/linux/libheif
LIBHEIF_WIN_PREFIX   := $(BUILD)/windows/libheif

LIBHEIF_TAR := $(TP)/libheif-$(LIBHEIF_VERSION).tar.gz

# -----------------------------
# Phony targets
# -----------------------------
.PHONY: linux_source_build_libheif mingw_source_build_libheif

# -----------------------------
# Extraction
# -----------------------------
# Linux
$(TP)/libheif-$(LIBHEIF_VERSION)-linux: $(LIBHEIF_TAR)
	@cd $(TP) && \
	tar -xvf $(notdir $<) && \
	mv libheif-$(LIBHEIF_VERSION) libheif-$(LIBHEIF_VERSION)-linux && \
	echo "Extracted libheif for Linux"

# MinGW
$(TP)/libheif-$(LIBHEIF_VERSION)-mingw: $(LIBHEIF_TAR)
	@cd $(TP) && \
	tar -xvf $(notdir $<) && \
	mv libheif-$(LIBHEIF_VERSION) libheif-$(LIBHEIF_VERSION)-mingw && \
	echo "Extracted libheif for MinGW"

# -----------------------------
# Linux build
# -----------------------------
linux_source_build_libheif: $(TP)/libheif-$(LIBHEIF_VERSION)-linux linux_source_build_libde265
	@echo "Building libheif for Linux..."
	@mkdir -p $(TP)/libheif-$(LIBHEIF_VERSION)-linux/build
	@cd $(TP)/libheif-$(LIBHEIF_VERSION)-linux/build && \
	cmake \
		-DCMAKE_BUILD_TYPE=Release \
		-DENABLE_EXAMPLES=OFF \
		-DENABLE_UTILS=OFF \
		-DWITH_EXAMPLES=OFF \
		-DCMAKE_INSTALL_PREFIX=$(TP)/libheif-$(LIBHEIF_VERSION)-linux/build/dist \
		-DLIBDE265_INCLUDE_DIR=$(BUILD)/linux/libde265/include \
		-DLIBDE265_LIBRARY=$(BUILD)/linux/libde265/lib/libde265.so \
		.. && \
	cmake --build . -- -j$(shell nproc) && \
	cmake --install . --prefix $(TP)/libheif-$(LIBHEIF_VERSION)-linux/build/dist
	@mkdir -p $(BUILD)/linux
	@if [ ! -d "$(LIBHEIF_LINUX_PREFIX)" ]; then \
		mv $(TP)/libheif-$(LIBHEIF_VERSION)-linux/build/dist $(LIBHEIF_LINUX_PREFIX); \
		echo "Moved libheif to $(LIBHEIF_LINUX_PREFIX)"; \
	fi

# -----------------------------
# MinGW build
# -----------------------------
mingw_source_build_libheif: $(TP)/libheif-$(LIBHEIF_VERSION)-mingw mingw_source_build_libde265
	@echo "Building libheif for Windows (MinGW)..."
	# copy MinGW toolchain file
	@cp $(CURDIR)/mingw-libheif-toolchain.cmake $(TP)/libheif-$(LIBHEIF_VERSION)-mingw/
	@mkdir -p $(TP)/libheif-$(LIBHEIF_VERSION)-mingw/build
	@cd $(TP)/libheif-$(LIBHEIF_VERSION)-mingw/build && \
	cmake \
		-DCMAKE_TOOLCHAIN_FILE=$(TP)/libheif-$(LIBHEIF_VERSION)-mingw/mingw-libheif-toolchain.cmake \
		-DCMAKE_BUILD_TYPE=Release \
		-DENABLE_EXAMPLES=OFF \
		-DENABLE_UTILS=OFF \
		-DWITH_EXAMPLES=OFF \
		-DCMAKE_INSTALL_PREFIX=$(TP)/libheif-$(LIBHEIF_VERSION)-mingw/build/dist \
		-DLIBDE265_INCLUDE_DIR=$(BUILD)/windows/libde265/include \
		-DLIBDE265_LIBRARY=$(BUILD)/windows/libde265/lib/libde265.dll.a \
		.. && \
	cmake --build . -- -j$(shell nproc) && \
	cmake --install . --prefix $(TP)/libheif-$(LIBHEIF_VERSION)-mingw/build/dist
	@mkdir -p $(BUILD)/windows
	@if [ ! -d "$(LIBHEIF_WIN_PREFIX)" ]; then \
		mv $(TP)/libheif-$(LIBHEIF_VERSION)-mingw/build/dist $(LIBHEIF_WIN_PREFIX); \
		echo "Moved libheif to $(LIBHEIF_WIN_PREFIX)"; \
	fi
