#!/bin/bash
#
# MusicBox startup script
#
# This script is executed by /etc/rc.local

# Set user vars
CONFIG_FILE=/boot/config/settings.ini

echo "************************"
echo "Initializing MusicBox..."
echo "************************"

# Load configuration
eval "$(/usr/local/bin/ini2env -file "${CONFIG_FILE}" | grep '^INI__.*=".*"$')"

# System setup
# shellcheck source=files/pimusicbox/bin/system.sh
. /opt/musicbox/bin/system.sh
resize_disk

# Setup network
# shellcheck source=files/pimusicbox/bin/network.sh
. /opt/musicbox/bin/network.sh
set_wifi
enable_ssh
