FROM debian:stretch AS build

RUN apt-get update && \
    apt-get install -y curl git build-essential libasound2-dev pkg-config

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin/:${PATH}"
RUN rustup target add arm-unknown-linux-gnueabihf

RUN mkdir /.cargo && \
    echo '[target.arm-unknown-linux-gnueabihf]\nlinker = "arm-linux-gnueabihf-gcc"' >> /.cargo/config

RUN mkdir /build
ENV CARGO_TARGET_DIR /build
ENV CARGO_HOME /build/cache

RUN git clone https://github.com/librespot-org/librespot.git /src
WORKDIR /src
RUN cargo build --release --no-default-features --features "alsa-backend"

FROM debian:stretch
RUN apt-get update && \
    apt-get install -y libasound2 mpc && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 4070
RUN mkdir /librespot
COPY --from=build /build/release/librespot /librespot/
COPY librespot_avahi.service /librespot/librespot_avahi.service
COPY start.sh /librespot/start.sh
ENTRYPOINT ["/librespot/start.sh"]
