#!/usr/bin/env bats
source ./files/pimusicbox/bin/setsound.sh

setup() {
    bats_load_library bats-support
    bats_load_library bats-assert
    bats_load_library bats-file

    TEST_TEMP_DIR="$(temp_make)"
    BATSLIB_FILE_PATH_REM="#${TEST_TEMP_DIR}"
    BATSLIB_FILE_PATH_ADD='<temp>'
    ETC_ASOUND_CONF="${TEST_TEMP_DIR}/asound.conf"
}

teardown() {
    temp_del "$TEST_TEMP_DIR"
}

@test "only sourcing the file does nothing" {
    run ./files/pimusicbox/bin/setsound.sh

    assert_success
    assert_output ''
}

function enumerate_alsa_cards() { printf "card 0 alsa bcm2835 alsa device 0 bcm2835 alsa bcm2835 alsa\ncard 0 alsa bcm2835 alsa device 1 bcm2835 alsa bcm2835 iec958hdmi"; }
export -f enumerate_alsa_cards

function get_output_and_alsa_card_id() { echo "get_output_and_alsa_card_id" $@; }
export -f get_output_and_alsa_card_id

function get_alsa_config() { echo "get_alsa_config" $@; }
export -f get_alsa_config

function set_alsa_mixer() { echo "set_alsa_mixer" $@; }
export -f set_alsa_mixer

@test "setsound() defaults to auto if INI__musicbox__output is not set" {
    unset INI__musicbox__output
    run setsound

    assert_success
    assert_file_exist $ETC_ASOUND_CONF
    echo "get_alsa_config get_output_and_alsa_card_id auto" | cmp -s $ETC_ASOUND_CONF -
}

@test "setsound() uses INI__musicbox__output if set" {
    INI__musicbox__output=analog
    run setsound
    assert_success
    assert_file_exist $ETC_ASOUND_CONF
    echo "get_alsa_config get_output_and_alsa_card_id analog" | cmp -s $ETC_ASOUND_CONF -

    INI__musicbox__output=hdmi
    run setsound
    assert_success
    echo "get_alsa_config get_output_and_alsa_card_id hdmi" | cmp -s $ETC_ASOUND_CONF -

    INI__musicbox__output=usb
    run setsound
    assert_success
    echo "get_alsa_config get_output_and_alsa_card_id usb" | cmp -s $ETC_ASOUND_CONF -
}
