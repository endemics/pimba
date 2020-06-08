lint:
	docker run --rm -v \
	  $(PWD):/src \
	  -w /src \
	  koalaman/shellcheck:v0.7.0 \
	    files/pimusicbox/startup.sh \
	    files/pimusicbox/bin/network.sh \
	    bin/shrink-img.sh

img:
	sudo env "PATH=$(PATH):$(HOME)/packer/bin:$(HOME)/qemu/bin:/usr/sbin:/sbin" ~/packer/bin/packer build packer.json
