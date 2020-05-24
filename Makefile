lint:
	docker run --rm -v \
	  $(PWD):/src \
	  -w /src \
	  koalaman/shellcheck:v0.7.0 \
	    -e SC2154 \
	    files/pimusicbox/startup.sh \
	    files/pimusicbox/bin/network.sh

img:
	sudo env "PATH=$(PATH):$(HOME)/packer/bin:$(HOME)/qemu/bin:/usr/sbin:/sbin" ~/packer/bin/packer build packer.json
