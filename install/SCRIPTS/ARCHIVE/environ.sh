#!/bin/bash

### gnu compiler and runtime
export RUNTIME="gnu"
export CC=gcc
export CXX=g++
#export OBJCFLAGS="-g -O0 -Wno-expansion-to-defined"
export OBJCFLAGS="-g -O0 -std=gnu11 -Wno-error=int-conversion -Wno-error=incompatible-pointer-types -Wno-unknown-pragmas -Wno-expansion-to-defined -Wno-unused-variable"
export CFLAGS="-g -O0 -std=gnu11 -Wno-error=incompatible-pointer-types"
export PATH="/System/bin:$PATH"
export MKARGS="-j`nproc`"
