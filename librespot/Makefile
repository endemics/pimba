all: build run

build:
	docker build -t pimba/librespot .

run:
	docker run -ti --rm \
	  --device /dev/snd \
	  -v /etc/asound.conf:/etc/asound.conf:ro \
	  -v /etc/avahi/services:/etc/avahi/services \
	  -p 4070:4070 \
	  pimba/librespot -n pi --zeroconf-port 4070
