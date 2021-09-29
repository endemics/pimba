#!/bin/bash
# Network config

WPA_CONF=/etc/wpa_supplicant/wpa_supplicant.conf

function set_wifi() {
    # shellcheck disable=SC2154
    if [ "$INI__network__wifi_network" != "" ]; then
        # Put wifi settings for wpa roaming
        #
        # If wifi_country is set then include a country=XX line
        # shellcheck disable=SC2154
        if [ "$INI__network__wifi_country" != "" ]; then
            if ! echo "$INI__network__wifi_country" | grep -qe '^[A-Z]\{2\}$'; then
                echo "ERROR: country code needs to be an uppercase ISO 3166-1 alpha-2 code." >&2
                echo "see https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2" >&2
                exit 1
            fi
            WIFICOUNTRY="country=$INI__network__wifi_country"
        else
            echo "WARNING: wifi_country is not set, skipping wifi configuration." >&2
            return
        fi

        # shellcheck disable=SC2154
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
            cat >"${WPA_CONF}" <<EOF
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
            cat >"${WPA_CONF}" <<EOF
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
        rfkill unblock wifi
        wpa_cli -i wlan0 reconfigure
    fi
}

function enable_ssh() {
    # shellcheck disable=SC2154
    if [ "$INI__network__enable_ssh" == "1" ]; then
        systemctl start ssh
    fi
}
