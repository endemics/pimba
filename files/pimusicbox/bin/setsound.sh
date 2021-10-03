#!/bin/bash
#
# MusicBox Sound configuration script

# The file containing the alsa configuration
ETC_ASOUND_CONF=/etc/asound.conf
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

# Given OUTPUT:CARD_ID, returns an appropriate alsa config on stdout
function get_alsa_config() {
    local OUTPUT
    local CARD

    if [ $# -ne 1 ] || (echo -n "$1" | grep -q -v -e '^[a-z]\+:[0-9]\+$'); then
        echo "ERROR: need to provide output:card_id as an argument" >&2
        return 1
    fi

    OUTPUT=$(echo "$1" | cut -d : -f 1)
    CARD=$(echo "$1" | cut -d : -f 2)

    # shellcheck disable=SC2154
    if [ "$OUTPUT" == "usb" ] && [ "$INI__musicbox__downsample_usb" == "1" ]; then
    # resamples to 44K because of problems with some usb-dacs on 48k (probably
    # related to usb drawbacks of Pi)
    cat << EOF
pcm.!default {
    type plug
    slave.pcm {
        type dmix
        ipc_key 1024
        slave {
            pcm "hw:$CARD"
            rate 44100
        }
    }
}
ctl.!default {
    type hw
    card $CARD
}
EOF
    else
    cat << EOF
pcm.!default {
    type hw
    card $CARD
}
ctl.!default {
    type hw
    card $CARD
}
EOF
    fi
}

# Given OUTPUT:CARD_ID, set alsa mixer and volume appropriately
function set_alsa_mixer() {
    local OUTPUT
    local CARD

    if [ $# -ne 1 ] || (echo -n "$1" | grep -q -v -e '^[a-z]\+:[0-9]\+$'); then
        echo "ERROR: need to provide output:card_id as an argument" >&2
        return 1
    fi

    OUTPUT=$(echo "$1" | cut -d : -f 1)
    CARD=$(echo "$1" | cut -d : -f 2)

    # Reset mixer
    amixer cset numid=3 0 2>&1 || true

    if [ "$OUTPUT" == "analog" ]; then
        amixer cset numid=3 1 2>&1 || true
    elif [ "$OUTPUT" == "hdmi" ]; then
        amixer cset numid=3 2 2>&1 || true
    fi

    # Set initial hardware volume
    for CTL in \
        Master \
        PCM \
        Line \
        "PCM,1" \
        Wave \
        Music \
        AC97 \
        "Master Digital" \
        DAC \
        "DAC,0" \
        "DAC,1" \
        Speaker \
        Playback \
        Digital \
        Aux \
        Front \
        Center
    do
        amixer set -c "$CARD" "$CTL" 96% unmute 2>&1 || true
    done

    # Set PCM of Pi higher, because it's really quiet otherwise (hardware thing)
    amixer -c 0 set PCM playback 98% 2>&1 || true &
}

# The function that wraps it all
function setsound() {
    local OUTPUT_CARDID
    local CONFIG

    # If no output was set in the configuration, default to 'auto'
    if [ -z "${INI__musicbox__output}" ]; then
        INI__musicbox__output=auto
    fi

    mapfile -t CARDS < <(enumerate_alsa_cards)
    OUTPUT_CARDID=$(get_output_and_alsa_card_id "${INI__musicbox__output}")
    CONFIG=$(get_alsa_config "${OUTPUT_CARDID}")

    # If alsa configuration has changed, overwrite existing configuration
    # Note: we use '-s' because '--silent' is not supported on busybox
    if ! echo "${CONFIG}" | cmp -s "${ETC_ASOUND_CONF}" -; then
        echo "${CONFIG}" > "${ETC_ASOUND_CONF}"
    fi

    set_alsa_mixer "${OUTPUT_CARDID}" > /dev/null
}
