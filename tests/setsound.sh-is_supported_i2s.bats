#!/usr/bin/env bats
load ${BATS_HELPERS_DIR}/bats-support/load.bash
load ${BATS_HELPERS_DIR}/bats-assert/load.bash
load ${BATS_HELPERS_DIR}/bats-file/load.bash

source ./files/pimusicbox/bin/setsound.sh

@test "is_supported_i2s() fails if no arguments provided" {
    run is_supported_i2s

    assert_failure 1
    assert_output --partial "ERROR: "
}

@test "is_supported_i2s() fails if too many arguments provided" {
    run is_supported_i2s foo bar baz

    assert_failure 1
    assert_output --partial "ERROR: "
}

@test "is_supported_i2s() returns success for supported cards" {
    for card in hifiberry_dac hifiberry_digi hifiberry_dacplus hifiberry_amp \
                justboom_dac justboom_digi \
                iqaudio_dacplus iqaudio_digi_wm8804_audio \
                audioinjector-wm8731-audio audioinjector-addons \
                allo-boss-dac allo-piano-dac allo-piano-dac-plus allo_digione \
                wolfson \
                phatdac
    do
        run is_supported_i2s $card

        assert_success
        assert_output ''
    done
}

@test "is_supported_i2s() returns failure for unsupported cards" {
    run is_supported_i2s foobar

    assert_failure 1
    assert_output --partial "ERROR:"
}
