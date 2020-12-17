#!/usr/bin/env bats
load ${BATS_HELPERS_DIR}/bats-support/load.bash
load ${BATS_HELPERS_DIR}/bats-assert/load.bash
load ${BATS_HELPERS_DIR}/bats-file/load.bash

source ./files/pimusicbox/bin/setsound.sh

@test "get_usb_id() reports the first usb device alsa id successfully if it exists" {
    CARDS=(
        'card 0 alsa bcm2835 alsa device 0 bcm2835 alsa bcm2835 alsa'
        'card 0 alsa bcm2835 alsa device 1 bcm2835 alsa bcm2835 iec958hdmi'
    )
    run get_usb_id

    assert_success
    assert_output ''

    CARDS=(
        'card 0 alsa bcm2835 alsa device 0 bcm2835 alsa bcm2835 alsa'
        'card 0 alsa bcm2835 alsa device 1 bcm2835 alsa bcm2835 iec958hdmi'
        'card 1 audio usb audio device 0 usb audio usb audio'
        'card 1 dac usb audio dac device 0 usb audio usb audio'
        'card 1 codec usb audio codec device 0 usb audio usb audio'
        'card 2 audio usb audio device 0 usb audio usb audio'
        'card 2 dac usb audio dac device 0 usb audio usb audio'
        'card 2 codec usb audio codec device 0 usb audio usb audio'
    )
    run get_usb_id

    assert_success
    assert_output '1'
}
