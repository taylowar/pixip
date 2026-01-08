# libde265.mk - builds libde265 for Linux or MinGW

# -----------------------------
# Variables (override from top Makefile if needed)
# -----------------------------
LIBDE265_VERSION := 1.0.16
TP := $(CURDIR)/thirdparty
BUILD := $(CURDIR)/build

LIBDE265_LINUX_PREFIX := $(BUILD)/linux/libde265
LIBDE265_WIN_PREFIX   := $(BUILD)/windows/libde265

LIBDE265_TAR := $(TP)/libde265-$(LIBDE265_VERSION).tar.gz

# -----------------------------
# Extraction rules
# -----------------------------
# Linux
$(TP)/libde265-$(LIBDE265_VERSION)-linux: $(LIBDE265_TAR)
	@cd $(TP) && \
	tar -xvf $(notdir $<) && \
	mv libde265-$(LIBDE265_VERSION) libde265-$(LIBDE265_VERSION)-linux && \
	echo "Extracted libde265 for Linux"

# Windows/MinGW
$(TP)/libde265-$(LIBDE265_VERSION)-mingw: $(LIBDE265_TAR)
	@cd $(TP) && \
	tar -xvf $(notdir $<) && \
	mv libde265-$(LIBDE265_VERSION) libde265-$(LIBDE265_VERSION)-mingw && \
	echo "Extracted libde265 for MinGW"

# -----------------------------
# Build rules
# -----------------------------
# Linux
linux_source_build_libde265: $(TP)/libde265-$(LIBDE265_VERSION)-linux
	@echo "Building libde265 for Linux..."
	@mkdir -p $(TP)/libde265-$(LIBDE265_VERSION)-linux/build
	@cd $(TP)/libde265-$(LIBDE265_VERSION)-linux/build && \
	cmake -DCMAKE_BUILD_TYPE=Release \
	      -DCMAKE_INSTALL_PREFIX=$(TP)/libde265-$(LIBDE265_VERSION)-linux/build/dist .. && \
	cmake --build . -- -j$(shell nproc) && \
	cmake --install . --prefix $(TP)/libde265-$(LIBDE265_VERSION)-linux/build/dist
	@mkdir -p $(BUILD)/linux
	@if [ ! -d "$(LIBDE265_LINUX_PREFIX)" ]; then \
		mv $(TP)/libde265-$(LIBDE265_VERSION)-linux/build/dist $(LIBDE265_LINUX_PREFIX); \
		echo "Moved libde265 to $(LIBDE265_LINUX_PREFIX)"; \
	fi

# Windows/MinGW
mingw_source_build_libde265: $(TP)/libde265-$(LIBDE265_VERSION)-mingw
	@echo "Building libde265 for MinGW..."
	# copy toolchain file
	@cp $(CURDIR)/mingw-libde265-toolchain.cmake $(TP)/libde265-$(LIBDE265_VERSION)-mingw/
	# create build folder
	@mkdir -p $(TP)/libde265-$(LIBDE265_VERSION)-mingw/build
	@cd $(TP)/libde265-$(LIBDE265_VERSION)-mingw/build && \
	cmake -DCMAKE_TOOLCHAIN_FILE=$(TP)/libde265-$(LIBDE265_VERSION)-mingw/mingw-libde265-toolchain.cmake \
	      -DCMAKE_BUILD_TYPE=Release \
	      -DCMAKE_INSTALL_PREFIX=$(TP)/libde265-$(LIBDE265_VERSION)-mingw/build/dist .. && \
	cmake --build . -- -j$(shell nproc) && \
	cmake --install . --prefix $(TP)/libde265-$(LIBDE265_VERSION)-mingw/build/dist
	# move to final staging directory
	@mkdir -p $(BUILD)/windows
	@if [ ! -d "$(LIBDE265_WIN_PREFIX)" ]; then \
		mv $(TP)/libde265-$(LIBDE265_VERSION)-mingw/build/dist $(LIBDE265_WIN_PREFIX); \
		echo "Moved libde265 to $(LIBDE265_WIN_PREFIX)"; \
	fi

# -----------------------------
# Clean
# -----------------------------
.PHONY: clean-libde265
clean-libde265:
	@rm -rf $(TP)/libde265-$(LIBDE265_VERSION)-linux
	@rm -rf $(TP)/libde265-$(LIBDE265_VERSION)-mingw
	@rm -rf $(LIBDE265_LINUX_PREFIX)
	@rm -rf $(LIBDE265_WIN_PREFIX)
