#!/bin/bash
#
# MusicBox Sound configuration script
#

function get_overlay() {
    local overlay=$1
    case $overlay in
        audioinjector-pi-soundcard)
            overlay="audioinjector-wm8731-audio"
            ;;
        audioinjector-octo-soundcard)
            overlay="audioinjector-addons"
            ;;
        iqaudio-dac)
            overlay="iqaudio-dacplus,unmute_amp"
            ;;
        allo-boss-dac)
            overlay="allo-boss-dac-pcm512x-audio"
            ;;
        allo-piano-dac)
            overlay="allo-piano-dac-pcm512x-audio"
            ;;
        allo-piano-dac-plus)
            overlay="allo-piano-dac-plus-pcm512x-audio"
            ;;
        *)
            ;;
    esac
    echo -n "${overlay}"
}
