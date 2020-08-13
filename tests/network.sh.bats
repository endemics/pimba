#!/usr/bin/env bats
load ${BATS_HELPERS_DIR}/bats-support/load.bash
load ${BATS_HELPERS_DIR}/bats-assert/load.bash
load ${BATS_HELPERS_DIR}/bats-file/load.bash

function systemctl() { echo "systemctl" $@; }

@test "empty environment does nothing" {

    run ./files/pimusicbox/bin/network.sh

    assert_success
    assert_output ''
}

@test "enable_ssh() does nothing if INI__network__enable_ssh is not defined" {
    export -f systemctl
    unset INI__network__enable_ssh
    source ./files/pimusicbox/bin/network.sh
    run enable_ssh

    assert_success
    assert_output ''
}

@test "enable_ssh() does nothing if INI__network__enable_ssh is defined but not equal 1" {
    export -f systemctl
    INI__network__enable_ssh=0
    source ./files/pimusicbox/bin/network.sh
    run enable_ssh

    assert_success
    assert_output ''
}

@test "enable_ssh() starts ssh if INI__network__enable_ssh is defined and equals 1" {
    export -f systemctl
    INI__network__enable_ssh=1
    source ./files/pimusicbox/bin/network.sh
    run enable_ssh

    assert_success
    assert_output 'systemctl start ssh'
}
