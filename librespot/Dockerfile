FROM debian:stretch AS build

RUN dpkg --add-architecture armhf && \
    apt-get update && \
    apt-get install -y curl \
        git build-essential \
        libasound2-dev pkg-config \
        crossbuild-essential-armhf libasound2-dev:armhf zlib1g-dev:armhf zlib1g-dev lib32z1

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin/:${PATH}"
RUN rustup target add armv7-unknown-linux-gnueabihf

RUN mkdir -p /.cargo && \
    echo '[target.armv7-unknown-linux-gnueabihf]\nlinker = "arm-linux-gnueabihf-gcc"' >> /.cargo/config

RUN cat /.cargo/config # DEBUG
RUN mkdir /build
ENV CARGO_TARGET_DIR /build
ENV CARGO_HOME /build/cache
ENV TARGET armv7-unknown-linux-gnueabihf

# alsa-sys :(
ENV  PKG_CONFIG_ALLOW_CROSS 1
ENV PKG_CONFIG_PATH /usr/lib/arm-linux-gnueabihf/pkgconfig

RUN git clone https://github.com/librespot-org/librespot.git /src
WORKDIR /src
RUN cargo build --release --no-default-features --features "alsa-backend" --target=armv7-unknown-linux-gnueabihf

FROM debian:stretch
RUN apt-get update && \
    apt-get install -y libasound2 mpc && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 4070
RUN mkdir /librespot
COPY --from=build /build/armv7-unknown-linux-gnueabihf/release/librespot /librespot/
COPY librespot_avahi.service /librespot/librespot_avahi.service
COPY start.sh /librespot/start.sh
ENTRYPOINT ["/librespot/start.sh"]
