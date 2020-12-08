#!/bin/bash
#
# MusicBox Sound configuration script

function enumerate_alsa_cards() {
    while read -r line; do
        echo "$line" | tr '[:upper:]' '[:lower:]' | tr -d '[:punct:]'
    done < <(aplay -l | grep card)
}
