#!/usr/bin/env bats
load ${BATS_HELPERS_DIR}/bats-support/load.bash
load ${BATS_HELPERS_DIR}/bats-assert/load.bash
load ${BATS_HELPERS_DIR}/bats-file/load.bash

source ./files/pimusicbox/bin/setsound.sh

@test "get_i2s_card_id() fails if no arguments provided" {
    run get_i2s_card_id

    assert_failure 1
    assert_output --partial "ERROR: "
}

@test "get_i2s_card_id() fails if too many arguments provided" {
    run get_i2s_card_id foo bar baz

    assert_failure 1
    assert_output --partial "ERROR: "
}

@test "get_i2s_card_id() reports the first alsa id successfully if i2s device exists" {
    CARDS=(
        'card 0 alsa bcm2835 alsa device 0 bcm2835 alsa bcm2835 alsa'
        'card 0 alsa bcm2835 alsa device 1 bcm2835 alsa bcm2835 iec958hdmi'
    )
    run get_i2s_card_id hifiberry_dacplus
    assert_success
    assert_output ''

    CARDS=(
        'card 0 alsa bcm2835 alsa device 0 bcm2835 alsa bcm2835 alsa'
        'card 0 alsa bcm2835 alsa device 1 bcm2835 alsa bcm2835 iec958hdmi'
        'card 1 sndrpihifiberry sndrpihifiberrydacplus device 0 hifiberry dac hifi pcm512xhifi0'
    )
    run get_i2s_card_id hifiberry_dacplus
    assert_success
    assert_output '1'

    CARDS=(
        'card 0 alsa bcm2835 alsa device 0 bcm2835 alsa bcm2835 alsa'
        'card 0 alsa bcm2835 alsa device 1 bcm2835 alsa bcm2835 iec958hdmi'
        'card 1 set cmedia usb headphone set device 0 usb audio usb audio'
        'card 2 sndrpihifiberry sndrpihifiberrydacplus device 0 hifiberry dac hifi pcm512xhifi0'
    )
    run get_i2s_card_id hifiberry_dacplus
    assert_success
    assert_output '2'

    CARDS=(
        'card 0 alsa bcm2835 alsa device 0 bcm2835 alsa bcm2835 alsa'
        'card 0 alsa bcm2835 alsa device 1 bcm2835 alsa bcm2835 iec958hdmi'
        'card 1 sndrpihifiberry sndrpihifiberrydacplus device 0 hifiberry dac hifi pcm512xhifi0'
        'card 2 sndrpihifiberry sndrpihifiberrydacplus device 0 hifiberry dac hifi pcm512xhifi0'
    )
    run get_i2s_card_id hifiberry_dacplus
    assert_success
    assert_output '1'
}
