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
test -f "qemu-$VERSION.tar.bz2" || wget -nv "https://download.qemu.org/qemu-$VERSION.tar.bz2"
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

echo "$VERSION $TARGETS" > $HOME/qemu/.build
echo -e "\033[32mQemu version ${VERSION} successfully build\033[0m"
