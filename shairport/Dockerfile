FROM alpine:edge as builder
ARG VERSION=3.3rc7
WORKDIR /root
RUN apk add --no-cache \
        git \
        build-base \
        autoconf \
        automake \
        libtool \
        alsa-lib-dev \
        libdaemon-dev \
        popt-dev \
        libressl-dev \
        soxr-dev \
        avahi-dev \
        libconfig-dev
RUN git clone -b ${VERSION} https://github.com/mikebrady/shairport-sync.git
WORKDIR /root/shairport-sync
RUN autoreconf -i -f \
        && ./configure \
          --with-alsa \
          --with-pipe \
          --with-avahi \
          --with-ssl=openssl \
          --with-soxr \
          --with-metadata \
        && make \
        && make install

FROM alpine:edge
RUN apk add --no-cache \
        dbus \
        alsa-lib \
        libdaemon \
        popt \
        libressl \
        soxr \
        avahi \
        libconfig
COPY --from=builder /root/shairport-sync/shairport-sync /usr/local/bin/shairport-sync
COPY start.sh /start
ENV AIRPLAY_NAME raspberrypi
ENTRYPOINT [ "/start" ]
