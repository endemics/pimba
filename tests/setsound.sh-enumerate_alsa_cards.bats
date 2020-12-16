#!/usr/bin/env bats
load ${BATS_HELPERS_DIR}/bats-support/load.bash
load ${BATS_HELPERS_DIR}/bats-assert/load.bash
load ${BATS_HELPERS_DIR}/bats-file/load.bash

source ./files/pimusicbox/bin/setsound.sh

@test "enumerate_alsa_cards() with no cards returns nothing" {
    function aplay() { echo ""; }
    export -f aplay
    run enumerate_alsa_cards

    assert_success
    assert_output ''
}

@test "enumerate_alsa_cards() with onboard cards returns 2 lines" {
    function aplay() { printf "card 0: ALSA [bcm2835 ALSA], device 0: bcm2835 ALSA [bcm2835 ALSA]\ngarbage\ncard 0: ALSA [bcm2835 ALSA], device 1: bcm2835 ALSA [bcm2835 IEC958/HDMI]"; }
    export -f aplay
    run enumerate_alsa_cards

    assert_success
    assert_line --index 0 'card 0 alsa bcm2835 alsa device 0 bcm2835 alsa bcm2835 alsa'
    assert_line --index 1 'card 0 alsa bcm2835 alsa device 1 bcm2835 alsa bcm2835 iec958hdmi'
}
