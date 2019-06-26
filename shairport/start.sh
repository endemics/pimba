#!/bin/sh
AIRPLAY_NAME=${AIRPLAY_NAME:-raspberrypi}
shairport-sync -m avahi -a "$AIRPLAY_NAME" "$@"
