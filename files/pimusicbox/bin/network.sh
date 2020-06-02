#!/bin/bash
# Network config

function set_wifi() {
    if [ "$INI__network__wifi_network" != "" ]; then
        # Put wifi settings for wpa roaming
        #
        # If wifi_country is set then include a country=XX line
        if [ "$INI__network__wifi_country" != "" ]; then
            WIFICOUNTRY="country=$INI__network__wifi_country"
        else
            WIFICOUNTRY=""
        fi

        if [ "$INI__network__wifi_password" != "" ]; then
            password_length=${#INI__network__wifi_password}
            # Passphrases are 8..63 character long.
            # If the value is longer, then we have a PSK that needs to
            # be provided unquoted
            if [ "$password_length" -gt 63 ]; then
                PSK="$INI__network__wifi_password"
            else
                PSK="\"$INI__network__wifi_password\""
            fi
            cat >/etc/wpa_supplicant/wpa_supplicant.conf <<EOF
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
$WIFICOUNTRY
network={
    ssid="$INI__network__wifi_network"
    psk=$PSK
    scan_ssid=1
}
EOF
        else
            # if no password is given, set key_mgmt to NONE
            cat >/etc/wpa_supplicant/wpa_supplicant.conf <<EOF
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
$WIFICOUNTRY
network={
    ssid="$INI__network__wifi_network"
    key_mgmt=NONE
    scan_ssid=1
}
EOF
        fi

        /sbin/wpa_cli -i wlan0 reconfigure
    fi
}
