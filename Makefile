all: zip

lint:
	docker run --rm -v \
	  $(PWD):/src \
	  -w /src \
	  koalaman/shellcheck:v0.7.0 \
	    files/pimusicbox/startup.sh \
	    files/pimusicbox/bin/network.sh \
	    files/pimusicbox/bin/system.sh \
	    bin/shrink-img.sh

test:
	docker run --rm \
	    -v $(PWD):/src \
	    -w /src \
	    dduportal/bats:1.1.0 tests/*.bats

img:
	sudo env "PATH=$(PATH):$(HOME)/packer/bin:$(HOME)/qemu/bin:/usr/sbin:/sbin" ~/packer/bin/packer build packer.json

shrink: img
	sudo bash -c "source bin/shrink-img.sh && shrink pimba.img"

img-test: shrink
	sudo env "PATH=$(PATH):$(HOME)/packer/bin:$(HOME)/qemu/bin:/usr/sbin:/sbin" ~/packer/bin/packer build \
	  -var "sha256_checksum=`sha256sum pimba.img| awk '{print $$1}'`" \
	  test.json

zip: img-test
	zip -1 pimba.img.zip pimba.img
