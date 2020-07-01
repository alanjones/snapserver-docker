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

FROM ubuntu:bionic AS shairport

RUN apt-get update \
 && apt-get -y install curl \
    autoconf \
    automake \
    avahi-daemon \
    build-essential \
    ca-certificates \
    dbus \
    git \
    libasound2-dev \
    libavahi-client-dev \
    libdaemon-dev \
    libpopt-dev \
    libssl-dev \
    libconfig-dev \
    libtool \
    supervisor \
    libportaudio2 \
    libvorbis0a \
    libavahi-client3 \
    libflac8 \
    libvorbisenc2 \
    libvorbisfile3 \
    libopus0 \
    libmosquitto-dev \
 && apt-get clean && rm -fR /var/lib/apt/lists

RUN cd /tmp \
 && git clone https://github.com/mikebrady/shairport-sync.git \
 && cd shairport-sync \
 && autoreconf -i -f \
 && ./configure --sysconfdir=/etc ./configure --with-stdout --with-avahi --with-ssl=openssl --with-metadata --with-mqtt-client\
 && make 

FROM ubuntu:bionic

ARG ARCH=amd64
ARG SNAPCAST_VERSION=0.19.0

RUN apt-get update \
 && apt-get -y install curl \
    avahi-daemon \
    ca-certificates \
    dbus \
    supervisor \
    libportaudio2 \
    libvorbis0a \
    libavahi-client3 \
    libflac8 \
    libvorbisenc2 \
    libvorbisfile3 \
    libopus0 \
    libasound2-dev \
    libavahi-client-dev \
    libdaemon-dev \
    libpopt-dev \
    libssl-dev \
    libconfig-dev \
    libtool \
    libmosquitto-dev \
 && apt-get clean && rm -fR /var/lib/apt/lists

RUN curl -sL -o /tmp/snapserver.deb https://github.com/badaix/snapcast/releases/download/v0.19.0/snapserver_0.19.0-1_amd64.deb \
 && dpkg -i /tmp/snapserver.deb \
 && rm /tmp/snapserver.deb

COPY --from=librespot /tmp/librespot/target/release/librespot /usr/local/bin/
COPY --from=shairport /tmp/shairport-sync/shairport-sync /usr/local/bin/

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY entrypoint.sh /
RUN chmod a+x /entrypoint.sh

CMD [ "/entrypoint.sh" ]
