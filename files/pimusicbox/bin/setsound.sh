#!/bin/bash
#
# MusicBox Sound configuration script

declare -a CARDS

function enumerate_alsa_cards() {
    while read -r line; do
        echo "$line" | tr '[:upper:]' '[:lower:]' | tr -d '[:punct:]'
    done < <(aplay -l | grep card)
}

# Remove special characters from string provided as argument
function clean_name() {
    echo "$1" | tr -d '[:punct:]'
}

# Retrieve the id of the alsa device corresponding to the internal soundcard
# (chipset bcm2835)
# Requires an enumerated list of alsa cards in the array CARDS
function get_internalcard_id() {
    printf '%s\n' "${CARDS[@]}" | grep -w bcm2835 | awk '{print $2}' | head -1
}

# Return 0 if there is some hdmi audio device detected by the internal
# soundcard, 1 otherwise
function internalcard_hdmi_activated() {
    if [ -n "$(tvservice -a 2>&1)" ]; then
        return 0
    else
        return 1
    fi
}

# Retrieve the id of the first "usb audio" alsa device
# Requires an enumerated list of alsa cards in the array CARDS
function get_usb_id() {
    printf '%s\n' "${CARDS[@]}" | grep 'usb audio' | awk '{print $2}' | head -1
}

# Given an OUTPUT setup, returns the actual output and alsa card id config on stdout
function get_output_and_alsa_card_id() {
    if [ $# -ne 1 ]; then
        echo "ERROR: need to provide output as an argument" >&2
        return 1
    fi

    local OUTPUT=$1
    local CARD
    case $OUTPUT in
        auto)
            # priority: USB > integrated HDMI > integrated analog
            CARD=$(get_usb_id)
            if [ -n "${CARD}" ]; then
                OUTPUT=usb
            else
                CARD=$(get_internalcard_id)
                if internalcard_hdmi_activated; then
                    OUTPUT=hdmi
                else
                    OUTPUT=analog
                fi
            fi
            ;;
        analog)
            CARD=$(get_internalcard_id)
            ;;
        hdmi)
            CARD=$(get_internalcard_id)
            if ! internalcard_hdmi_activated; then
                echo "ERROR: no audio hdmi detected, falling back to analog output" >&2
                OUTPUT=analog
            fi
            ;;
        usb)
            CARD=$(get_usb_id)
            ;;
        *)
            return 1
            ;;
    esac

    if [ -z "${CARD}" ]; then
        echo "****************************" >&2
        echo "WARNING: No audio card found" >&2
        echo "****************************" >&2
        exit 1
    else
        echo -n "${OUTPUT}:${CARD}"
    fi
}
