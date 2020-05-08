FROM rust:1.42 AS librespot

RUN apt-get update \
 && apt-get -y install build-essential portaudio19-dev curl unzip \
 && apt-get clean && rm -fR /var/lib/apt/lists

ARG LIBRESPOT_VERSION=0.1.1

RUN cd /tmp \
 && curl -sLO https://github.com/librespot-org/librespot/archive/v0.1.1.zip \
 && unzip v${LIBRESPOT_VERSION}.zip \
 && mv librespot-${LIBRESPOT_VERSION} librespot \
 && cd librespot \
 && cargo build --release \
 && chmod +x target/release/librespot

FROM ubuntu:bionic

RUN apt-get update \
 && apt-get -y install curl libportaudio2 libvorbis0a libavahi-client3 libflac8 libvorbisenc2 libvorbisfile3 libopus0 \
 && apt-get clean && rm -fR /var/lib/apt/lists

ARG ARCH=amd64
ARG SNAPCAST_VERSION=0.19.0

RUN curl -sL -o /tmp/snapserver.deb https://github.com/badaix/snapcast/releases/download/v0.19.0/snapserver_0.19.0-1_amd64.deb \
 && dpkg -i /tmp/snapserver.deb \
 && rm /tmp/snapserver.deb

COPY --from=librespot /tmp/librespot/target/release/librespot /usr/local/bin/

COPY entrypoint.sh /
RUN chmod a+x /entrypoint.sh

CMD [ "/entrypoint.sh" ]
