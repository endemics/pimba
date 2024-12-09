#!/bin/bash
set -e

VERSION=${PACKER_VERSION:=1.7.3}

if echo "${VERSION}" | cmp --silent ${HOME}/packer/.build -; then
  echo "packer ${VERSION} up to date!"
  exit 0
fi

echo "VERSION: ${VERSION}"

cd ${HOME}
rm -rf packer
mkdir -p packer/{bin,build}

# Checking for a tarball before downloading makes testing easier :-)
test -f "packer_${VERSION}_linux_amd64.zip" || wget -nv "https://releases.hashicorp.com/packer/${VERSION}/packer_${VERSION}_linux_amd64.zip"
unzip "packer_${VERSION}_linux_amd64.zip" -d packer/bin

cd ${HOME}/packer/build
git clone https://github.com/solo-io/packer-plugin-arm-image.git/
cd packer-plugin-arm-image
git checkout v0.2.0
go mod download
go build
mv packer-plugin-arm-image ${HOME}/packer/bin/packer-plugin-arm-image

echo "${VERSION}" > ${HOME}/packer/.build
echo -e "\033[32mPacker version ${VERSION} successfully build\033[0m"
