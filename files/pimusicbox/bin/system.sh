#!/bin/bash
# System config

function resize_disk() {
    # shellcheck disable=SC2154
    if [ "$INI__musicbox__resize_once" == "1" ]; then
        # set resize_once=false in ini file
        sed -i -e "/^\[musicbox\]/,/^\[.*\]/ s|^\(resize_once[ \t]*=[ \t]*\).*$|\1false\r|" "${CONFIG_FILE}"
        echo "Performing resize..."
        raspi-config nonint do_expand_rootfs
        reboot
    fi
}

function change_root_password() {
    # shellcheck disable=SC2154
    if [ "$INI__musicbox__root_password" != "" ] && [ "$INI__musicbox__root_password" != "musicbox" ]; then
        echo "Setting root user password..."
        echo "root:$INI__musicbox__root_password" | chpasswd
        # remove password from ini file
        sed -i -e "/^\[musicbox\]/,/^\[.*\]/ s|^\(root_password[ \t]*=[ \t]*\).*$|\1\r|" "${CONFIG_FILE}"
    fi
}
