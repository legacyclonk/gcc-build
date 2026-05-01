#!/bin/bash

set -e

VERSION=16.1.0
MAJOR=$(echo "$VERSION" | cut -d . -f 1)
MAKE_CMD="make -j$(nproc)"
MIRROR="https://ftp.mpi-inf.mpg.de/mirrors/gnu/mirror/gcc.gnu.org/pub/gcc"
BUILD_ROOT=$PWD

case "$GCC_ARCH" in
	"")
		echo "GCC_ARCH must be set!" >&2
		exit 1
		;;

	"x86_64")
		ARCH_FLAGS=(--with-abi=m64 --build=x86_64-linux-gnu --host=x86_64-linux-gnu --target=x86_64-linux-gnu)
		;;

	"aarch64")
		ARCH_FLAGS=(--host=aarch64-unknown-linux-gnu --build=aarch64-unknown-linux-gnu --with-arch=armv8-a)
		;;
esac

mkdir output

curl -L "$MIRROR/releases/gcc-$VERSION/gcc-$VERSION.tar.xz" | tar xJ
mkdir build && cd build
"../gcc-$VERSION/configure" -v --enable-languages=c,c++ --enable-lto --prefix=/usr --with-gcc-major-version-only --program-suffix="-$MAJOR" --program-prefix="$GCC_ARCH-linux-gnu-" --enable-shared --enable-linker-build-id --libexecdir=/usr/lib --without-included-gettext --enable-threads=posix --libdir=/usr/lib --enable-nls --enable-clocale=gnu --enable-libstdcxx-debug --enable-libstdcxx-time=yes --with-default-libstdcxx-abi=new --enable-gnu-unique-object --disable-vtable-verify --enable-plugin --enable-default-pie --with-system-zlib --with-target-system-zlib=auto --enable-multiarch --disable-werror  --with-tune=generic  --disable-multilib --enable-checking=no,assert "${ARCH_FLAGS[@]}"

$MAKE_CMD
$MAKE_CMD DESTDIR="$PWD/destdir" install
cd destdir
tar cf "$BUILD_ROOT/output/gcc-$VERSION-$GCC_ARCH.tar.zst" --zstd -- *
