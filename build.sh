#!/bin/bash

set -e

SNAPSHOT=13-20230422
MAKE_CMD="make -j$(nproc)"
BUILD_ROOT=$PWD

mkdir output

sudo DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y build-essential flex bison zlib1g-dev libmpc-dev libmpfr-dev libgmp-dev g++
curl -L "https://gcc.gnu.org/pub/gcc/snapshots/$SNAPSHOT/gcc-$SNAPSHOT.tar.xz" | tar xJ
curl -L https://github.com/mathstuf/gcc/commit/3075e510e3d29583f8886b95aff044c0474c84a5.patch -o modules.patch
pushd "gcc-$SNAPSHOT"
patch -p1 <../modules.patch || true
popd
mkdir build && cd build
"../gcc-$SNAPSHOT/configure" -v --enable-languages=c,c++ --prefix=/usr --with-gcc-major-version-only --program-suffix=-13 --program-prefix=x86_64-linux-gnu- --enable-shared --enable-linker-build-id --libexecdir=/usr/lib --without-included-gettext --enable-threads=posix --libdir=/usr/lib --enable-nls --enable-clocale=gnu --enable-libstdcxx-debug --enable-libstdcxx-time=yes --with-default-libstdcxx-abi=new --enable-gnu-unique-object --disable-vtable-verify --enable-plugin --enable-default-pie --with-system-zlib --with-target-system-zlib=auto --enable-multiarch --disable-werror --with-abi=m64 --with-tune=generic --build=x86_64-linux-gnu --host=x86_64-linux-gnu --target=x86_64-linux-gnu --disable-multilib --enable-checking=no,assert

$MAKE_CMD
$MAKE_CMD DESTDIR=$PWD/destdir install
cd destdir
tar cf "$BUILD_ROOT/output/gcc-$SNAPSHOT.tar.zst" --zstd -- *
