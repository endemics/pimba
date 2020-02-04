#!/bin/bash
set -e

VERSION=${PACKER_VERSION:=1.5.1}

if echo "${VERSION}" | cmp --silent ${HOME}/packer/.build -; then
  echo "packer ${VERSION} up to date!"
  exit 0
fi

echo "VERSION: ${VERSION}"

cd ${HOME}
rm -rf packer
mkdir -p packer/{bin,build}

# Checking for a tarball before downloading makes testing easier :-)
test -f "packer_${VERSION}_linux_arm64.zip" || wget "https://releases.hashicorp.com/packer/${VERSION}/packer_${VERSION}_linux_arm64.zip"
unzip "packer_${VERSION}_linux_arm64.zip" -d packer/bin

echo "${VERSION}" > ${HOME}/packer/.build
