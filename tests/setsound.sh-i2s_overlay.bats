#!/usr/bin/env bats
load ${BATS_HELPERS_DIR}/bats-support/load.bash
load ${BATS_HELPERS_DIR}/bats-assert/load.bash
load ${BATS_HELPERS_DIR}/bats-file/load.bash

source ./files/pimusicbox/bin/setsound.sh

@test "i2s_overlay() fails if no arguments provided" {
    run i2s_overlay

    assert_failure 1
    assert_output --partial "ERROR: "
}

@test "i2s_overlay() fails if too many arguments provided" {
    run i2s_overlay foo bar baz

    assert_failure 1
    assert_output --partial "ERROR: "
}

@test "i2s_overlay() returns specific overlay for iqaudio-dacplus" {
    run i2s_overlay iqaudio-dacplus

    assert_success
    assert_output 'iqaudio-dacplus,unmute_amp'
}

@test "i2s_overlay() returns specific overlay for allo-boss-dac" {
    run i2s_overlay allo-boss-dac

    assert_success
    assert_output 'allo-boss-dac-pcm512x-audio'
}

@test "i2s_overlay() returns specific overlay for allo-piano-dac" {
    run i2s_overlay allo-piano-dac

    assert_success
    assert_output 'allo-piano-dac-pcm512x-audio'
}

@test "i2s_overlay() returns specific overlay for allo-piano-dac-plus" {
    run i2s_overlay allo-piano-dac-plus

    assert_success
    assert_output 'allo-piano-dac-plus-pcm512x-audio'
}

@test "i2s_overlay() returns specific overlay for wolfson" {
    run i2s_overlay wolfson

    assert_success
    assert_output 'wsp'
}

@test "i2s_overlay() returns specific overlay for phatdac" {
    run i2s_overlay phatdac

    assert_success
    assert_output 'hifiberry_dac'
}

@test "i2s_overlay() returns card name for supported cards with no special overlay" {
    for card in hifiberry_dac hifiberry_digi hifiberry_dacplus hifiberry_amp \
                justboom_dac justboom_digi \
                iqaudio_digi_wm8804_audio \
                audioinjector-wm8731-audio audioinjector-addons \
                allo_digione
    do
        run i2s_overlay $card

        assert_success
        assert_output "$card"
    done
}
