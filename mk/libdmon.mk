# libdmon.mk - builds libdmon for Linux and MinGW

# -----------------------------
# Variables
# -----------------------------
LIBDMON_LINUX_SRC := $(CURDIR)/src/dmon_posix.cpp
LIBDMON_WIN_SRC := $(CURDIR)/src/dmon_windows.cpp
BUILD := $(CURDIR)/build

LIBDMON_LINUX_PREFIX := $(BUILD)/linux/libdmon
LIBDMON_WIN_PREFIX   := $(BUILD)/windows/libdmon

# -----------------------------
# Phony targets
# -----------------------------
.PHONY: linux_source_build_libdmon mingw_source_build_libdmon clean-libdmon

# -----------------------------
# Linux build
# -----------------------------
linux_source_build_libdmon: $(LIBDMON_LINUX_SRC)
	@echo "Building libdmon for Linux..."
	@mkdir -p $(BUILD)/linux
	@mkdir -p $(LIBDMON_LINUX_PREFIX)/lib
	$(CXX) -fPIC -Wall -Wextra -shared -o $(LIBDMON_LINUX_PREFIX)/lib/libdmon.so $(LIBDMON_LINUX_SRC)
	@mkdir -p $(LIBDMON_LINUX_PREFIX)/include
	@cp $(CURDIR)/src/dmon.h $(LIBDMON_LINUX_PREFIX)/include

# -----------------------------
# MinGW build
# -----------------------------
mingw_source_build_libdmon: $(LIBDMON_WIN_SRC)
	error "not implemented yet"

# -----------------------------
# Clean
# -----------------------------
clean-libdmon:
	@rm -rf $(LIBDMON_LINUX_PREFIX)
	@rm -rf $(LIBDMON_WIN_PREFIX)
