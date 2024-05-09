#!/bin/bash

set -e

VERSION=14.1.0
MAJOR=14
MAKE_CMD="make -j$(nproc)"
BUILD_ROOT=$PWD

mkdir output

sudo DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y build-essential flex bison zlib1g-dev libmpc-dev libmpfr-dev libgmp-dev g++
curl -L "https://sourceware.org/pub/gcc/releases/gcc-$VERSION/gcc-$VERSION.tar.xz" | tar xJ
mkdir build && cd build
"../gcc-$VERSION/configure" -v --enable-languages=c,c++ --prefix=/usr --with-gcc-major-version-only --program-suffix=-$MAJOR --program-prefix=x86_64-linux-gnu- --enable-shared --enable-linker-build-id --libexecdir=/usr/lib --without-included-gettext --enable-threads=posix --libdir=/usr/lib --enable-nls --enable-clocale=gnu --enable-libstdcxx-debug --enable-libstdcxx-time=yes --with-default-libstdcxx-abi=new --enable-gnu-unique-object --disable-vtable-verify --enable-plugin --enable-default-pie --with-system-zlib --with-target-system-zlib=auto --enable-multiarch --disable-werror --with-abi=m64 --with-tune=generic --build=x86_64-linux-gnu --host=x86_64-linux-gnu --target=x86_64-linux-gnu --disable-multilib --enable-checking=no,assert

$MAKE_CMD
$MAKE_CMD DESTDIR=$PWD/destdir install
cd destdir
tar cf "$BUILD_ROOT/output/gcc-$VERSION.tar.zst" --zstd -- *
