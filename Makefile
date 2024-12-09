all: zip

lint:
	docker run --rm -v \
	  $(PWD):/src \
	  -w /src \
	  koalaman/shellcheck:v0.7.2 \
	    files/pimusicbox/startup.sh \
	    files/pimusicbox/bin/network.sh \
	    files/pimusicbox/bin/system.sh \
	    files/pimusicbox/bin/setsound.sh \
	    bin/shrink-img.sh
	@echo "\033[32mLint OK\033[0m"

test:
	docker run --rm \
	    -v $(PWD):/src \
	    -w /src \
	    bats/bats:1.11.1 tests/*.bats
	@echo "\033[32mPimba scripts test OK\033[0m"

img:
	sudo env "PATH=$(PATH):$(HOME)/packer/bin:$(HOME)/qemu/bin:/usr/sbin:/sbin" ~/packer/bin/packer build packer.json
	@echo "\033[32mpimba.img build OK\033[0m"

shrink: img
	sudo bash -c "source bin/shrink-img.sh && shrink pimba.img"
	@echo "\033[32mPimba image shrink OK\033[0m"

img-test: shrink
	sudo env "PATH=$(PATH):$(HOME)/packer/bin:$(HOME)/qemu/bin:/usr/sbin:/sbin" ~/packer/bin/packer build \
	  -var "sha256_checksum=`sha256sum pimba.img| awk '{print $$1}'`" \
	  test.json
	@echo "\033[32mIn-image serverspec tests OK\033[0m"

zip: img-test
	zip -1 pimba.img.zip pimba.img
	@echo "\033[32mImage compression OK\033[0m"
