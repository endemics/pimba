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
