#!/bin/sh
trap cleanup 0 1 2 3 6 15

cleanup() {
  echo "Removing avahi service file"
  rm -f /etc/avahi/services/librespot_avahi.service
  exit
}

cp /librespot/librespot_avahi.service /etc/avahi/services/librespot_avahi.service
/librespot/librespot "$@"
