#!/usr/bin/env bats
load ${BATS_HELPERS_DIR}/bats-support/load.bash
load ${BATS_HELPERS_DIR}/bats-assert/load.bash
load ${BATS_HELPERS_DIR}/bats-file/load.bash

source ./files/pimusicbox/bin/setsound.sh

@test "only sourcing the file does nothing" {
    run ./files/pimusicbox/bin/setsound.sh

    assert_success
    assert_output ''
}

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

@test "clean_name()" {
    run clean_name
    assert_success
    assert_output ''

    run clean_name aaa
    assert_success
    assert_output 'aaa'

    run clean_name aAa
    assert_success
    assert_output 'aAa'

    run clean_name a-a
    assert_success
    assert_output 'aa'

    run clean_name "[aa]"
    assert_success
    assert_output 'aa'

    run clean_name _-.
    assert_success
    assert_output ''
}

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

@test "internalcard_hdmi_activated() returns 1 if no hdmi output detected on the internal card" {
    function tvservice() { echo ''; }
    export -f tvservice
    run internalcard_hdmi_activated

    assert_failure 1
    assert_output ''
}

@test "internalcard_hdmi_activated() returns 0 if there is an hdmi audio output detected on the internal card" {
    function tvservice() { echo '     AC3 supported: Max channels: 6, Max samplerate:  48kHz, Max rate  640 kb/s.'; }
    export -f tvservice
    run internalcard_hdmi_activated

    assert_success
    assert_output ''
}

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
