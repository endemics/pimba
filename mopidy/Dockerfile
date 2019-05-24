FROM python:2.7-alpine3.8
RUN apk add --no-cache \
    ca-certificates \
    build-base \
    libffi-dev \
    coreutils \
    libxml2-dev \
    libxslt-dev \
    gstreamer \
    gst-plugins-bad \
    gst-plugins-base \
    gst-plugins-good \
    gst-plugins-ugly \
    gstreamer-tools \
    py2-gst \
    py-gobject

RUN wget https://mopidy.github.io/libspotify-archive/libspotify-12.1.103-Linux-armv6-bcm2708hardfp-release.tar.gz && \
    tar xvzf libspotify-12.1.103-Linux-armv6-bcm2708hardfp-release.tar.gz && \
    cd libspotify-12.1.103-Linux-armv6-bcm2708hardfp-release/ && \
    make install; \
    cd .. && \
    rm -rf libspotify-12.1.103-Linux-armv6-bcm2708hardfp-release*

RUN pip install -U \
    mopidy \
    mopidy-spotify \
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

ENV PYTHONPATH /usr/lib/python2.7/site-packages:

EXPOSE 6600 6680

ENTRYPOINT ["/usr/local/bin/mopidy"]
