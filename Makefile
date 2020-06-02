lint:
	docker run --rm -v \
	  $(PWD):/src \
	  -w /src \
	  koalaman/shellcheck:v0.7.0 \
	    -e SC2154 \
	    files/pimusicbox/startup.sh \
	    files/pimusicbox/bin/network.sh

test:
	docker run --rm \
	    -v $(PWD):/src \
	    -w /src \
	    dduportal/bats:1.1.0 tests/*.bats

img:
	sudo env "PATH=$(PATH):$(HOME)/packer/bin:$(HOME)/qemu/bin:/usr/sbin:/sbin" ~/packer/bin/packer build packer.json
