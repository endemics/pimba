#!/usr/bin/env bats
load ${BATS_HELPERS_DIR}/bats-support/load.bash
load ${BATS_HELPERS_DIR}/bats-assert/load.bash
load ${BATS_HELPERS_DIR}/bats-file/load.bash

source ./files/pimusicbox/bin/setsound.sh

@test "get_internalcard_id() reports the internal card alsa id successfully if it exists" {
    CARDS=(
        'card 0 sndrpihifiberry sndrpihifiberrydacplus device 0 hifiberry dac hifi pcm512xhifi0 '
    )
    run get_internalcard_id

    assert_success
    assert_output ''

    CARDS=(
        'card 0 alsa bcm2835 alsa device 0 bcm2835 alsa bcm2835 alsa'
        'card 0 alsa bcm2835 alsa device 1 bcm2835 alsa bcm2835 iec958hdmi'
    )
    run get_internalcard_id

    assert_success
    assert_output '0'
}
