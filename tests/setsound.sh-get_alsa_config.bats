#!/usr/bin/env bats
setup() {
    bats_load_library bats-support
    bats_load_library bats-assert
    bats_load_library bats-file
}

source ./files/pimusicbox/bin/setsound.sh

@test "get_alsa_config() fails if no argument provided" {
    run get_alsa_config

    assert_failure 1
    assert_output --partial "ERROR: "
}

@test "get_alsa_config() fails if argument has incorrect format" {
    run get_alsa_config analog
    assert_failure 1
    assert_output --partial "ERROR: "

    run get_alsa_config analog1
    assert_failure 1
    assert_output --partial "ERROR: "

    run get_alsa_config foo-bar:1
    assert_failure 1
    assert_output --partial "ERROR: "

    run get_alsa_config foo:a
    assert_failure 1
    assert_output --partial "ERROR: "

    run get_alsa_config foo:1:1
    assert_failure 1
    assert_output --partial "ERROR: "
}

@test "get_alsa_config() returns valid alsa config for analog" {
    run get_alsa_config analog:1

    assert_success
    assert_output 'pcm.!default {
    type hw
    card 1
}
ctl.!default {
    type hw
    card 1
}'
}

@test "get_alsa_config() returns valid alsa config for hdmi" {
    run get_alsa_config hdmi:0

    assert_success
    assert_output 'pcm.!default {
    type hw
    card 0
}
ctl.!default {
    type hw
    card 0
}'
}

@test "get_alsa_config() returns valid alsa config for usb when downsampling is not set or equals 0" {
    unset INI__musicbox__downsample_usb
    run get_alsa_config usb:1

    assert_success
    assert_output 'pcm.!default {
    type hw
    card 1
}
ctl.!default {
    type hw
    card 1
}'

    INI__musicbox__downsample_usb=0
    run get_alsa_config usb:2
    assert_success
    assert_output 'pcm.!default {
    type hw
    card 2
}
ctl.!default {
    type hw
    card 2
}'
}

@test "get_alsa_config() returns valid alsa config for usb when downsampling is set" {
    INI__musicbox__downsample_usb=1
    run get_alsa_config usb:1

    assert_success
    assert_output 'pcm.!default {
    type plug
    slave.pcm {
        type dmix
        ipc_key 1024
        slave {
            pcm "hw:1"
            rate 44100
        }
    }
}
ctl.!default {
    type hw
    card 1
}'
}
