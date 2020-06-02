#!/usr/bin/env bats
load ${BATS_HELPERS_DIR}/bats-support/load.bash
load ${BATS_HELPERS_DIR}/bats-assert/load.bash

@test "empty environment does nothing" {

    run ./files/pimusicbox/bin/network.sh

    assert_success
    assert_output ''
}
