img:
	sudo env "PATH=$(PATH):$(HOME)/packer/bin:$(HOME)/qemu/bin:/usr/sbin:/sbin" ~/packer/bin/packer build packer.json
