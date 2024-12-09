#!/usr/bin/env bats
setup() {
    bats_load_library bats-support
    bats_load_library bats-assert
    bats_load_library bats-file
}

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
