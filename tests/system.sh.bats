#!/usr/bin/env bats
load ${BATS_HELPERS_DIR}/bats-support/load.bash
load ${BATS_HELPERS_DIR}/bats-assert/load.bash
load ${BATS_HELPERS_DIR}/bats-file/load.bash

source ./files/pimusicbox/bin/system.sh

setup() {
    TEST_TEMP_DIR="$(temp_make)"
    BATSLIB_FILE_PATH_REM="#${TEST_TEMP_DIR}"
    BATSLIB_FILE_PATH_ADD='<temp>'
    export CONFIG_FILE="${TEST_TEMP_DIR}/settings.ini"
    cat > "${CONFIG_FILE}" <<EOF
[musicbox]
resize_once = true
root_password = barbaz
EOF
}

teardown() {
    temp_del "$TEST_TEMP_DIR"
}

function raspi-config() { echo "raspi-config" "$@"; }
function reboot() { echo "reboot" "$@"; }
function chpasswd() { xargs echo chpasswd; }

@test "only sourcing the file does nothing" {

    run ./files/pimusicbox/bin/system.sh

    assert_success
    assert_output ''
}

@test "resize_disk() does nothing if INI__musicbox__resize_once is not defined" {
    export -f raspi-config
    export -f reboot
    unset INI__musicbox__resize_once
    run resize_disk

    assert_success
    assert_output ''
}

@test "resize_disk() does nothing if INI__musicbox__resize_once does not equal 1" {
    export -f raspi-config
    export -f reboot
    INI__musicbox__resize_once=0
    run resize_disk

    assert_success
    assert_output ''
}

@test "resize_disk() calls resize and reboots if INI__musicbox__resize_once is set to 1" {
    export -f raspi-config
    export -f reboot
    INI__musicbox__resize_once=1
    run resize_disk

    assert_success
    assert grep '^resize_once = false\r$' "${CONFIG_FILE}"
    assert_output 'Performing resize...
raspi-config nonint do_expand_rootfs
reboot'
}


@test "change_root_password() does nothing if INI__musicbox__root_password is not defined" {
    export -f chpasswd
    unset INI__musicbox__root_password
    run change_root_password

    assert_success
    assert grep '^root_password = barbaz$' "${CONFIG_FILE}"
    assert_output ''
}

@test "change_root_password() does nothing if INI__musicbox__root_password is defined to musicbox" {
    export -f chpasswd
    INI__musicbox__root_password=musicbox
    run change_root_password

    assert_success
    assert grep '^root_password = barbaz$' "${CONFIG_FILE}"
    assert_output ''
}

@test "change_root_password() changes password if INI__musicbox__root_password is defined and different from musicbox" {
    export -f chpasswd
    INI__musicbox__root_password=foobaz
    run change_root_password

    assert_success
    assert grep '^root_password = \r$' "${CONFIG_FILE}"
    assert_output 'Setting root user password...
chpasswd root:foobaz'
}
