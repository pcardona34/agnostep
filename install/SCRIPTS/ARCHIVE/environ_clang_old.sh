#!/bin/bash

### clang compiler and objc2 runtime
CLANG_VERSION=14
GS_RT_VERSION=2.1
CPUS=`nproc`
export MKARGS="j-${CPUS}"
export CC=/usr/bin/clang-${CLANG_VERSION}
export CXX=/usr/bin/clang++-${CLANG_VERSION}
export RUNTIME="ng"
export RUNTIME_VERSION=gnustep-${GS_RT_VERSION}
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
#export LD=/usr/bin/ld.gold
export LD=/usr/bin/ld.lld-${CLANG_VERSION}
export LDFLAGS="-fuse-ld=${LD} -L/usr/local/lib"
export OBJCFLAGS="-g -O0 -fblocks -Wno-error=implicit-function-declaration"
