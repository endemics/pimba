#!/usr/bin/env bats
load ${BATS_HELPERS_DIR}/bats-support/load.bash
load ${BATS_HELPERS_DIR}/bats-assert/load.bash
load ${BATS_HELPERS_DIR}/bats-file/load.bash

source ./files/pimusicbox/bin/setsound.sh

@test "get_output_and_alsa_card_id() fails if no argument provided" {
    run get_output_and_alsa_card_id

    assert_failure 1
    assert_output --partial "ERROR: "
}

@test "get_output_and_alsa_card_id() returns an error if no sound card can be found" {
    function get_internalcard_id() { echo ''; }
    export -f get_internalcard_id

    function get_usb_id() { echo ''; }
    export -f get_usb_id

    run get_output_and_alsa_card_id auto
    assert_failure 1
    assert_output '****************************
WARNING: No audio card found
****************************'

    run get_output_and_alsa_card_id usb
    assert_failure 1
    assert_output '****************************
WARNING: No audio card found
****************************'

    run get_output_and_alsa_card_id hdmi
    assert_failure 1
    assert_output '****************************
WARNING: No audio card found
****************************'

    run get_output_and_alsa_card_id analog
    assert_failure 1
    assert_output '****************************
WARNING: No audio card found
****************************'
}

@test "get_output_and_alsa_card_id() returns valid output and card id for analog" {
    function get_internalcard_id() { echo '0'; }
    export -f get_internalcard_id

    run get_output_and_alsa_card_id analog

    assert_success
    assert_output 'analog:0'
}

@test "get_output_and_alsa_card_id() returns valid output and card id for hdmi if connected" {
    function get_internalcard_id() { echo '0'; }
    export -f get_internalcard_id

    function internalcard_hdmi_activated() { return 0; }
    export -f internalcard_hdmi_activated

    run get_output_and_alsa_card_id hdmi

    assert_success
    assert_output 'hdmi:0'
}

@test "get_output_and_alsa_card_id() fallsback to analog for hdmi if not connected" {
    function get_internalcard_id() { echo '0'; }
    export -f get_internalcard_id

    function internalcard_hdmi_activated() { return 1; }
    export -f internalcard_hdmi_activated

    run get_output_and_alsa_card_id hdmi

    assert_success
    assert_output 'ERROR: no audio hdmi detected, falling back to analog output
analog:0'
}

@test "get_output_and_alsa_card_id() returns valid output and card id for usb" {
    function get_usb_id() { echo '0'; }
    export -f get_usb_id

    run get_output_and_alsa_card_id usb

    assert_success
    assert_output 'usb:0'
}

@test "get_output_and_alsa_card_id() auto privileges usb if present" {
    function get_usb_id() { echo '1'; }
    export -f get_usb_id

    run get_output_and_alsa_card_id auto

    assert_success
    assert_output 'usb:1'
}

@test "get_output_and_alsa_card_id() auto selects hdmi over analog if usb no present and hdmi connected" {
    function get_usb_id() { echo ''; }
    export -f get_usb_id

    function get_internalcard_id() { echo '0'; }
    export -f get_internalcard_id

    function internalcard_hdmi_activated() { return 0; }
    export -f internalcard_hdmi_activated

    run get_output_and_alsa_card_id auto

    assert_success
    assert_output 'hdmi:0'
}

@test "get_output_and_alsa_card_id() auto defaults to analog" {
    function get_usb_id() { echo ''; }
    export -f get_usb_id

    function get_internalcard_id() { echo '0'; }
    export -f get_internalcard_id

    function internalcard_hdmi_activated() { return 1; }
    export -f internalcard_hdmi_activated

    run get_output_and_alsa_card_id auto

    assert_success
    assert_output 'analog:0'
}
