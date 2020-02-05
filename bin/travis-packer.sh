#!/bin/bash
set -e

VERSION=${PACKER_VERSION:=1.5.1}
ARCH=${PACKER_ARCH:=arm64}

if echo "${VERSION}-${ARCH}" | cmp --silent ${HOME}/packer/.build -; then
  echo "packer ${VERSION} for ${ARCH} is up to date!"
  exit 0
fi

echo "VERSION: ${VERSION}"
echo "ARCH: ${ARCH}"

cd ${HOME}
rm -rf packer
mkdir -p packer/{bin,build}

# Checking for a tarball before downloading makes testing easier :-)
test -f "packer_${VERSION}_linux_${ARCH}.zip" || wget "https://releases.hashicorp.com/packer/${VERSION}/packer_${VERSION}_linux_${ARCH}.zip"
unzip "packer_${VERSION}_linux_${ARCH}.zip" -d packer/bin

cd ${HOME}/packer/build
git clone https://github.com/solo-io/packer-builder-arm-image
cd packer-builder-arm-image
go mod download
go build
mv packer-builder-arm-image ${HOME}/packer/bin/packer-builder-arm-image

echo "${VERSION}-${ARCH}" > ${HOME}/packer/.build
