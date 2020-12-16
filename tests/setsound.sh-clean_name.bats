#!/usr/bin/env bats
load ${BATS_HELPERS_DIR}/bats-support/load.bash
load ${BATS_HELPERS_DIR}/bats-assert/load.bash
load ${BATS_HELPERS_DIR}/bats-file/load.bash

source ./files/pimusicbox/bin/setsound.sh

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
