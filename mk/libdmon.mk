# libdmon.mk - builds libdmon for Linux and MinGW

# -----------------------------
# Variables
# -----------------------------
LIBDMON_LINUX_SRC := $(CURDIR)/src/dmon/dmon_posix.cpp
LIBDMON_WIN32_SRC := $(CURDIR)/src/dmon/dmon_win32.cpp
BUILD := $(CURDIR)/build

LIBDMON_LINUX_PREFIX := $(BUILD)/linux/libdmon
LIBDMON_WIN32_PREFIX   := $(BUILD)/windows/libdmon

# -----------------------------
# Phony targets
# -----------------------------
.PHONY: linux_source_build_libdmon mingw_source_build_libdmon

# -----------------------------
# Linux build
# -----------------------------
linux_source_build_libdmon: $(LIBDMON_LINUX_SRC)
	@echo "Building libdmon for Linux..."
	@mkdir -p $(BUILD)/linux
	@mkdir -p $(LIBDMON_LINUX_PREFIX)/lib
	$(CXX) -fPIC -Wall -Wextra -shared -o $(LIBDMON_LINUX_PREFIX)/lib/libdmon.so $(LIBDMON_LINUX_SRC)
	@mkdir -p $(LIBDMON_LINUX_PREFIX)/include
	@cp $(CURDIR)/src/dmon/dmon.h $(LIBDMON_LINUX_PREFIX)/include

# -----------------------------
# MinGW build
# -----------------------------
mingw_source_build_libdmon: $(LIBDMON_WIN32_SRC)
	@echo "Building libdmon for MinGW..."
	@mkdir -p $(BUILD)/windows
	@mkdir -p $(LIBDMON_WIN32_PREFIX)/bin
	$(MINGW_CXX) -fPIC -shared -Wall -Wextra -o $(LIBDMON_WIN32_PREFIX)/bin/libdmon.dll $(LIBDMON_WIN32_SRC)
	@mkdir -p $(LIBDMON_WIN32_PREFIX)/lib
	@cp $(LIBDMON_WIN32_PREFIX)/bin/libdmon.dll $(LIBDMON_WIN32_PREFIX)/lib
	@mkdir -p $(LIBDMON_WIN32_PREFIX)/include
	@cp $(CURDIR)/src/dmon/dmon.h $(LIBDMON_WIN32_PREFIX)/include
