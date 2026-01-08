# libjpeg.mk - builds libjpeg for Linux and MinGW
# Depends on libde265

# -----------------------------
# Variables
# -----------------------------
LIBJPEG_VERSION := turbo-3.1.2
TP := $(CURDIR)/thirdparty
BUILD := $(CURDIR)/build

LINUX_PREFIX := $(BUILD)/linux/libjpeg
WIN_PREFIX   := $(BUILD)/windows/libjpeg

LIBJPEG_TAR := $(TP)/libjpeg-$(LIBJPEG_VERSION).tar.gz

# -----------------------------
# Phony targets
# -----------------------------
.PHONY: linux_source_build_libjpeg mingw_source_build_libjpeg clean-libjpeg

# -----------------------------
# Extraction
# -----------------------------
# Linux
$(TP)/libjpeg-$(LIBJPEG_VERSION)-linux: $(LIBJPEG_TAR)
	@cd $(TP) && \
	tar -xvf $(notdir $<) && \
	mv libjpeg-$(LIBJPEG_VERSION) libjpeg-$(LIBJPEG_VERSION)-linux && \
	echo "Extracted libjpeg for Linux"

# MinGW
$(TP)/libjpeg-$(LIBJPEG_VERSION)-mingw: $(LIBJPEG_TAR)
	@cd $(TP) && \
	tar -xvf $(notdir $<) && \
	mv libjpeg-$(LIBJPEG_VERSION) libjpeg-$(LIBJPEG_VERSION)-mingw && \
	echo "Extracted libjpeg for MinGW"

# -----------------------------
# Linux build
# -----------------------------
linux_source_build_libjpeg: $(TP)/libjpeg-$(LIBJPEG_VERSION)-linux linux_source_build_libde265
	@echo "Building libjpeg for Linux..."
	@mkdir -p $(TP)/libjpeg-$(LIBJPEG_VERSION)-linux/build
	@cd $(TP)/libjpeg-$(LIBJPEG_VERSION)-linux/build && \
	cmake \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_INSTALL_PREFIX=$(TP)/libjpeg-$(LIBJPEG_VERSION)-linux/build/dist \
		-DLIBDE265_INCLUDE_DIR=$(BUILD)/linux/libde265/include \
		-DLIBDE265_LIBRARY=$(BUILD)/linux/libde265/lib/libde265.so \
		.. && \
	cmake --build . -- -j$(shell nproc) && \
	cmake --install . --prefix $(TP)/libjpeg-$(LIBJPEG_VERSION)-linux/build/dist
	@mkdir -p $(BUILD)/linux
	@if [ ! -d "$(LINUX_PREFIX)" ]; then \
		mv $(TP)/libjpeg-$(LIBJPEG_VERSION)-linux/build/dist $(LINUX_PREFIX); \
		echo "Moved libjpeg to $(LINUX_PREFIX)"; \
	fi

# -----------------------------
# MinGW build
# -----------------------------
mingw_source_build_libjpeg: $(TP)/libjpeg-$(LIBJPEG_VERSION)-mingw mingw_source_build_libde265
	@echo "Building libjpeg for Windows (MinGW)..."
	# copy MinGW toolchain file
	@cp $(CURDIR)/mingw-libjpeg-toolchain.cmake $(TP)/libjpeg-$(LIBJPEG_VERSION)-mingw/
	@mkdir -p $(TP)/libjpeg-$(LIBJPEG_VERSION)-mingw/build
	@cd $(TP)/libjpeg-$(LIBJPEG_VERSION)-mingw/build && \
	cmake \
		-DCMAKE_TOOLCHAIN_FILE=$(TP)/libjpeg-$(LIBJPEG_VERSION)-mingw/mingw-libjpeg-toolchain.cmake \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_INSTALL_PREFIX=$(TP)/libjpeg-$(LIBJPEG_VERSION)-mingw/build/dist \
		-DLIBDE265_INCLUDE_DIR=$(BUILD)/windows/libde265/include \
		-DLIBDE265_LIBRARY=$(BUILD)/windows/libde265/lib/libde265.dll.a \
		.. && \
	cmake --build . -- -j$(shell nproc) && \
	cmake --install . --prefix $(TP)/libjpeg-$(LIBJPEG_VERSION)-mingw/build/dist
	@mkdir -p $(BUILD)/windows
	@if [ ! -d "$(WIN_PREFIX)" ]; then \
		mv $(TP)/libjpeg-$(LIBJPEG_VERSION)-mingw/build/dist $(WIN_PREFIX); \
		echo "Moved libjpeg to $(WIN_PREFIX)"; \
	fi

# -----------------------------
# Clean
# -----------------------------
clean-libjpeg:
	@rm -rf $(TP)/libjpeg-$(LIBJPEG_VERSION)-linux
	@rm -rf $(TP)/libjpeg-$(LIBJPEG_VERSION)-mingw
	@rm -rf $(LINUX_PREFIX)
	@rm -rf $(WIN_PREFIX)
