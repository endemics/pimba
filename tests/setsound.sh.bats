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

@test "get_overlay() returns expected result for known overlays" {
    inputs=( \
        "audioinjector-pi-soundcard" \
        "audioinjector-octo-soundcard" \
        "iqaudio-dac" \
        "allo-boss-dac" \
        "allo-piano-dac" \
        "allo-piano-dac-plus" \
    )
    outputs=( \
        "audioinjector-wm8731-audio" \
        "audioinjector-addons" \
        "iqaudio-dacplus,unmute_amp" \
        "allo-boss-dac-pcm512x-audio" \
        "allo-piano-dac-pcm512x-audio" \
        "allo-piano-dac-plus-pcm512x-audio" \
    )

    for i in ${!inputs[@]}; do
        run get_overlay "${inputs[$i]}"

        assert_success
        assert_output "${outputs[$i]}"
    done
}

@test "get_overlay() returns expected result for unknown overlay" {
    run get_overlay foobarbaz

    assert_success
    assert_output "foobarbaz"
}
