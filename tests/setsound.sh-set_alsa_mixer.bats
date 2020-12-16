#!/usr/bin/env bats
load ${BATS_HELPERS_DIR}/bats-support/load.bash
load ${BATS_HELPERS_DIR}/bats-assert/load.bash
load ${BATS_HELPERS_DIR}/bats-file/load.bash

source ./files/pimusicbox/bin/setsound.sh

@test "set_alsa_mixer() fails if argument has incorrect format" {
    run set_alsa_mixer analog
    assert_failure 1
    assert_output --partial "ERROR: "

    run set_alsa_mixer analog1
    assert_failure 1
    assert_output --partial "ERROR: "

    run set_alsa_mixer foo-bar:1
    assert_failure 1
    assert_output --partial "ERROR: "

    run set_alsa_mixer foo:a
    assert_failure 1
    assert_output --partial "ERROR: "

    run set_alsa_mixer foo:1:1
    assert_failure 1
    assert_output --partial "ERROR: "
}

@test "set_alsa_mixer() sets amixer correctly for usb" {
    function amixer() { echo "amixer" $@; }
    export -f amixer

    run set_alsa_mixer usb:6

    assert_success
    assert_output 'amixer cset numid=3 0
amixer set -c 6 Master 96% unmute
amixer set -c 6 PCM 96% unmute
amixer set -c 6 Line 96% unmute
amixer set -c 6 PCM,1 96% unmute
amixer set -c 6 Wave 96% unmute
amixer set -c 6 Music 96% unmute
amixer set -c 6 AC97 96% unmute
amixer set -c 6 Master Digital 96% unmute
amixer set -c 6 DAC 96% unmute
amixer set -c 6 DAC,0 96% unmute
amixer set -c 6 DAC,1 96% unmute
amixer set -c 6 Speaker 96% unmute
amixer set -c 6 Playback 96% unmute
amixer set -c 6 Digital 96% unmute
amixer set -c 6 Aux 96% unmute
amixer set -c 6 Front 96% unmute
amixer set -c 6 Center 96% unmute
amixer -c 0 set PCM playback 98%'
}

@test "set_alsa_mixer() sets amixer correctly for analog" {
    function amixer() { echo "amixer" $@; }
    export -f amixer

    run set_alsa_mixer analog:6

    assert_success
    assert_output 'amixer cset numid=3 0
amixer cset numid=3 1
amixer set -c 6 Master 96% unmute
amixer set -c 6 PCM 96% unmute
amixer set -c 6 Line 96% unmute
amixer set -c 6 PCM,1 96% unmute
amixer set -c 6 Wave 96% unmute
amixer set -c 6 Music 96% unmute
amixer set -c 6 AC97 96% unmute
amixer set -c 6 Master Digital 96% unmute
amixer set -c 6 DAC 96% unmute
amixer set -c 6 DAC,0 96% unmute
amixer set -c 6 DAC,1 96% unmute
amixer set -c 6 Speaker 96% unmute
amixer set -c 6 Playback 96% unmute
amixer set -c 6 Digital 96% unmute
amixer set -c 6 Aux 96% unmute
amixer set -c 6 Front 96% unmute
amixer set -c 6 Center 96% unmute
amixer -c 0 set PCM playback 98%'
}

@test "set_alsa_mixer() sets amixer correctly for hdmi" {
    function amixer() { echo "amixer" $@; }
    export -f amixer

    run set_alsa_mixer hdmi:6

    assert_success
    assert_output 'amixer cset numid=3 0
amixer cset numid=3 2
amixer set -c 6 Master 96% unmute
amixer set -c 6 PCM 96% unmute
amixer set -c 6 Line 96% unmute
amixer set -c 6 PCM,1 96% unmute
amixer set -c 6 Wave 96% unmute
amixer set -c 6 Music 96% unmute
amixer set -c 6 AC97 96% unmute
amixer set -c 6 Master Digital 96% unmute
amixer set -c 6 DAC 96% unmute
amixer set -c 6 DAC,0 96% unmute
amixer set -c 6 DAC,1 96% unmute
amixer set -c 6 Speaker 96% unmute
amixer set -c 6 Playback 96% unmute
amixer set -c 6 Digital 96% unmute
amixer set -c 6 Aux 96% unmute
amixer set -c 6 Front 96% unmute
amixer set -c 6 Center 96% unmute
amixer -c 0 set PCM playback 98%'
}
