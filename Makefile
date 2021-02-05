# Makefile for CVE-2019-2215
# CREDIT: This file was editied from an original version made by CloudFuzz, which can be found here:
# https://github.com/cloudfuzz/android-kernel-exploitation/blob/master/exploit/Makefile

# Example usage:
# NDK_ROOT=~/Android/Sdk/ndk/22.0.7026061 make build-exploit push-exploit

CXX             := clang
CXXFLAGS        := -static -O3 -Wall -Wextra

ARCH            := x86_64
NDK_API         ?= 29
CROSS_COMPILE   := $(NDK_ROOT)/toolchains/llvm/prebuilt/linux-x86_64
TARGET_PLATFORM := $(ARCH)-linux-android

CXX_PATH        := $(CROSS_COMPILE)/bin/$(TARGET_PLATFORM)$(NDK_API)-$(CXX)

EXPLOIT_SRC     := exploit.c
EXPLOIT_OUTPUT  := cve-2019-2215-exploit

# default rule
default: all

# phony rules
.PHONY: all

all: clean build-exploit

clean:
	@echo Removing: $(EXPLOIT_OUTPUT)
	@rm -f $(EXPLOIT_OUTPUT)

build-exploit:
	@echo Building: $(EXPLOIT_OUTPUT)
	@$(CXX_PATH) $(CXXFLAGS) -o $(EXPLOIT_OUTPUT) $(EXPLOIT_SRC)

push-exploit:
	@echo Pushing: $(EXPLOIT_OUTPUT) to /data/local/tmp
	@adb push $(EXPLOIT_OUTPUT) /data/local/tmp
	@echo File located in: /data/local/tmp/$(EXPLOIT_OUTPUT)
