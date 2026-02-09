# libjpeg.mk - builds libjpeg for Linux and MinGW

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
linux_source_build_libjpeg: $(TP)/libjpeg-$(LIBJPEG_VERSION)-linux
	@echo "Building libjpeg for Linux..."
	@mkdir -p $(TP)/libjpeg-$(LIBJPEG_VERSION)-linux/build
	@cd $(TP)/libjpeg-$(LIBJPEG_VERSION)-linux/build && \
	cmake \
		-DCMAKE_BUILD_TYPE=Release \
		-DENABLE_EXAMPLES=OFF \
		-DENABLE_UTILS=OFF \
		-DWITH_EXAMPLES=OFF \
		-DCMAKE_INSTALL_PREFIX=$(TP)/libjpeg-$(LIBJPEG_VERSION)-linux/build/dist \
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
mingw_source_build_libjpeg: $(TP)/libjpeg-$(LIBJPEG_VERSION)-mingw
	@echo "Building libjpeg for Windows (MinGW)..."
	# copy MinGW toolchain file
	@cp $(CURDIR)/mingw-libjpeg-toolchain.cmake $(TP)/libjpeg-$(LIBJPEG_VERSION)-mingw/
	@mkdir -p $(TP)/libjpeg-$(LIBJPEG_VERSION)-mingw/build
	@cd $(TP)/libjpeg-$(LIBJPEG_VERSION)-mingw/build && \
	cmake \
		-DCMAKE_TOOLCHAIN_FILE=$(TP)/libjpeg-$(LIBJPEG_VERSION)-mingw/mingw-libjpeg-toolchain.cmake \
		-DCMAKE_BUILD_TYPE=Release \
		-DENABLE_EXAMPLES=OFF \
		-DENABLE_UTILS=OFF \
		-DWITH_EXAMPLES=OFF \
		-DCMAKE_INSTALL_PREFIX=$(TP)/libjpeg-$(LIBJPEG_VERSION)-mingw/build/dist \
		-DCMAKE_SYSTEM_PROCESSOR=x86_64 \
		-DWITH_SIMD=OFF \
		-DCPU_TYPE=x86_64 \
		-DCPU_BITS=64 \
		.. && \
	cmake --build . -- -j$(shell nproc) && \
	cmake --install . --prefix $(TP)/libjpeg-$(LIBJPEG_VERSION)-mingw/build/dist
	@mkdir -p $(BUILD)/windows
	@if [ ! -d "$(WIN_PREFIX)" ]; then \
		mv $(TP)/libjpeg-$(LIBJPEG_VERSION)-mingw/build/dist $(WIN_PREFIX); \
		echo "Moved libjpeg to $(WIN_PREFIX)"; \
	fi
