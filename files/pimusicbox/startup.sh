#!/bin/bash
#
# MusicBox startup script
#
# This script is executed by /etc/rc.local

# Set user vars
CONFIG_FILE=/boot/config/settings.ini
NAME="MusicBox"
DEFAULT_ROOT_PASSWORD="musicbox"

echo "************************"
echo "Initializing MusicBox..."
echo "************************"

# Load configuration
eval "$(/usr/local/bin/ini2env -file "${CONFIG_FILE}" | grep '^INI__.*=".*"$')"

# Setup network
/opt/musicbox/bin/network.sh
