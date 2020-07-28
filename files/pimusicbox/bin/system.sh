#!/bin/bash
# System config

function resize_disk() {
    # shellcheck disable=SC2154
    if [ "$INI__musicbox__resize_once" == "1" ]; then
        # set resize_once=false in ini file
        sed -i -e "/^\[musicbox\]/,/^\[.*\]/ s|^\(resize_once[ \t]*=[ \t]*\).*$|\1false\r|" "${CONFIG_FILE}"
        echo "Performing resize..."
        /usr/bin/raspi-config nonint do_expand_rootfs
    fi
}
