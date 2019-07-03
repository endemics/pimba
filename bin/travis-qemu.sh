#!/bin/bash
set -e

VERSION=${QEMU_VERSION:=4.0.0}
ARCHES=${QEMU_ARCHES:=arm}
TARGETS=${QEMU_TARGETS:=$(echo $ARCHES | sed 's#$# #;s#\([^ ]*\) #\1-softmmu \1-linux-user #g')}

if echo "$VERSION $TARGETS" | cmp --silent $HOME/qemu/.build -; then
  echo "qemu $VERSION up to date!"
  exit 0
fi

echo "VERSION: $VERSION"
echo "TARGETS: $TARGETS"

cd $HOME
rm -rf qemu

# Checking for a tarball before downloading makes testing easier :-)
test -f "qemu-$VERSION.tar.bz2" || wget "http://wiki.qemu-project.org/download/qemu-$VERSION.tar.bz2"
tar -xjf "qemu-$VERSION.tar.bz2"
cd "qemu-$VERSION"

./configure \
  --prefix="$HOME/qemu" \
  --target-list="$TARGETS" \
  --disable-docs \
  --disable-sdl \
  --disable-gtk \
  --disable-gnutls \
  --disable-gcrypt \
  --disable-nettle \
  --disable-curses \
  --static

make -j4
make install

# Install the good stuff from https://github.com/dhruvvyas90/qemu-rpi-kernel
mkdir -p $HOME/qemu/rpi-kernel
wget 'https://github.com/dhruvvyas90/qemu-rpi-kernel/blob/master/versatile-pb.dtb?raw=true' -O $HOME/qemu/rpi-kernel/versatile-pb.dtb
wget 'https://github.com/dhruvvyas90/qemu-rpi-kernel/blob/master/kernel-qemu-4.14.79-stretch?raw=true' -O $HOME/qemu/rpi-kernel/kernel-qemu-4.14.79-stretch

echo "$VERSION $TARGETS" > $HOME/qemu/.build
