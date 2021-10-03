#!/usr/bin/env bats
load ${BATS_HELPERS_DIR}/bats-support/load.bash
load ${BATS_HELPERS_DIR}/bats-assert/load.bash
load ${BATS_HELPERS_DIR}/bats-file/load.bash

source ./files/pimusicbox/bin/setsound.sh

@test "get_i2s_alsa_name() fails if no arguments provided" {
    run get_i2s_alsa_name

    assert_failure 1
    assert_output --partial "ERROR: "
}

@test "get_i2s_alsa_name() fails if too many arguments provided" {
    run get_i2s_alsa_name foo bar baz

    assert_failure 1
    assert_output --partial "ERROR: "
}

@test "get_i2s_alsa_name() returns wsp for wolfson card" {
    run get_i2s_alsa_name wolfson

    assert_success
    assert_output "wsp"
}

@test "get_i2s_alsa_name() returns iqaudio-dac for iqaudio-dacplus card" {
    run get_i2s_alsa_name iqaudio-dacplus

    assert_success
    assert_output "iqaudio-dac"
}

@test "get_i2s_alsa_name() returns audioinjector-pi-soundcard for audioinjector-wm8731-audio card" {
    run get_i2s_alsa_name audioinjector-wm8731-audio

    assert_success
    assert_output "audioinjector-pi-soundcard"
}

@test "get_i2s_alsa_name() returns audioinjector-octo-soundcard for audioinjector-addons card" {
    run get_i2s_alsa_name audioinjector-addons

    assert_success
    assert_output "audioinjector-octo-soundcard"
}

@test "get_i2s_alsa_name() returns hifiberry_dac and a warning for phatdac card" {
    run get_i2s_alsa_name phatdac

    assert_success
    assert_output --partial "WARNING:"
    assert_line --index 1 "hifiberry_dac"
}

@test "get_i2s_alsa_name() returns argument for anything not a special case" {
    run get_i2s_alsa_name hifiberry_dacplus
    assert_success
    assert_output "hifiberry_dacplus"

    run get_i2s_alsa_name random_garbage
    assert_success
    assert_output "random_garbage"
}
