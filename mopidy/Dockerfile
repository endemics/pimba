FROM debian:stretch
RUN apt-get update && apt-get install -y \
    build-essential python-dev python-pip \
    git wget \
    libffi-dev libasound2-dev pkg-config \
    libxml2-dev libxslt-dev libz-dev \
    python-gst-1.0 \
    gir1.2-gstreamer-1.0 gir1.2-gst-plugins-base-1.0 \
    gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly \
    gstreamer1.0-tools gstreamer1.0-alsa

RUN wget https://mopidy.github.io/libspotify-archive/libspotify-12.1.103-Linux-armv6-bcm2708hardfp-release.tar.gz && \
    tar xvzf libspotify-12.1.103-Linux-armv6-bcm2708hardfp-release.tar.gz && \
    cd libspotify-12.1.103-Linux-armv6-bcm2708hardfp-release/ && \
    make install; \
    cd .. && \
    rm -rf libspotify-12.1.103-Linux-armv6-bcm2708hardfp-release*

RUN pip install -U \
    mopidy==2.3.1 \
    mopidy-local-sqlite \
    mopidy-scrobbler \
    mopidy-soundcloud \
    mopidy-dirble \
    mopidy-tunein \
    mopidy-gmusic \
    mopidy-mobile \
    mopidy-moped \
    mopidy-musicbox-webclient \
    mopidy-websettings \
    mopidy-internetarchive \
    mopidy-podcast \
    mopidy-podcast-itunes \
    Mopidy-Simple-Webclient \
    mopidy-somafm \
    mopidy-spotify-tunigo \
    youtube-dl \
    mopidy-youtube

# Fix mopidy-youtube
WORKDIR /root
#RUN git clone https://github.com/natumbri/mopidy-youtube.git && \
#    cd mopidy-youtube && \
#    git checkout v2.1.0 && \
#    python2 setup.py build install && \
#    cd .. && \
#    rm -rf mopidy-youtube

# Fix mopidy-spotify using kingosticks web api playlist branch
RUN git clone https://github.com/kingosticks/mopidy-spotify.git && \
    cd mopidy-spotify && \
    git checkout fix/web-api-playlists-v2 && \
    python2 setup.py build install && \
    cd .. && \
    rm -rf mopidy-spotify

COPY logging.conf /etc/mopidy/

EXPOSE 6600 6680

ENTRYPOINT ["/usr/local/bin/mopidy"]
