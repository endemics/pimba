#!/bin/bash
#
# MusicBox Sound configuration script

function enumerate_alsa_cards() {
    while read -r line; do
        echo "$line" | tr '[:upper:]' '[:lower:]' | tr -d '[:punct:]'
    done < <(aplay -l | grep card)
}

# Remove special characters from string provided as argument
function clean_name() {
    echo $(echo "$1" | tr -d '[:punct:]')
}

# Retrieve the id of the alsa device corresponding to the internal soundcard
# (chipset bcm2835)
# Requires an enumerated list of alsa cards in the array CARDS
function get_internalcard_id() {
    printf '%s\n' "${CARDS[@]}" | grep -w bcm2835 | awk '{print $2}' | head -1
}

# Retrieve the id of the first "usb audio" alsa device
# Requires an enumerated list of alsa cards in the array CARDS
function get_usb_id() {
    printf '%s\n' "${CARDS[@]}" | grep 'usb audio' | awk '{print $2}' | head -1
}
