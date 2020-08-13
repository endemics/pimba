#!/usr/bin/env bats
load ${BATS_HELPERS_DIR}/bats-support/load.bash
load ${BATS_HELPERS_DIR}/bats-assert/load.bash
load ${BATS_HELPERS_DIR}/bats-file/load.bash

source ./files/pimusicbox/bin/network.sh

setup() {
    TEST_TEMP_DIR="$(temp_make)"
    BATSLIB_FILE_PATH_REM="#${TEST_TEMP_DIR}"
    BATSLIB_FILE_PATH_ADD='<temp>'
    WPA_CONF="${TEST_TEMP_DIR}/wpa.conf"
}

teardown() {
    temp_del "$TEST_TEMP_DIR"
}

function systemctl() { echo "systemctl" $@; }
function wpa_cli() { echo "wpa_cli" $@; }

function assert_wpa() {
    assert grep "$@" "${WPA_CONF}"
}

function refute_wpa() {
    refute grep "$@" "${WPA_CONF}"
}

@test "only sourcing the file does nothing" {

    run ./files/pimusicbox/bin/network.sh

    assert_success
    assert_output ''
}

@test "enable_ssh() does nothing if INI__network__enable_ssh is not defined" {
    export -f systemctl
    unset INI__network__enable_ssh
    run enable_ssh

    assert_success
    assert_output ''
}

@test "enable_ssh() does nothing if INI__network__enable_ssh is defined but not equal 1" {
    export -f systemctl
    INI__network__enable_ssh=0
    run enable_ssh

    assert_success
    assert_output ''
}

@test "enable_ssh() starts ssh if INI__network__enable_ssh is defined and equals 1" {
    export -f systemctl
    INI__network__enable_ssh=1
    run enable_ssh

    assert_success
    assert_output 'systemctl start ssh'
}

@test "set_wifi() does nothing if INI__network__wifi_network is not defined" {
    export -f wpa_cli
    unset INI__network__wifi_network
    run set_wifi

    assert_success
    assert_file_not_exist "${WPA_CONF}"
    assert_output ''
}

@test "set_wifi() does nothing if INI__network__wifi_network is empty" {
    export -f wpa_cli
    INI__network__wifi_network=''
    run set_wifi

    assert_success
    assert_file_not_exist "${WPA_CONF}"
    assert_output ''
}

@test "set_wifi() with network name, no country and no password" {
    export -f wpa_cli
    INI__network__wifi_network='foobar'
    unset INI__network__wifi_country
    run set_wifi

    assert_success
    assert_wpa 'ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev'
    refute_wpa 'country='
    assert_wpa 'update_config=1'
    assert_wpa '  *ssid="foobar"'
    assert_wpa '  *key_mgmt=NONE'
    assert_wpa '  *scan_ssid=1'
    assert_output 'wpa_cli -i wlan0 reconfigure'
}

@test "set_wifi() with network name, country but no password" {
    export -f wpa_cli
    INI__network__wifi_network='foobar'
    INI__network__wifi_country=AU
    run set_wifi

    assert_success
    assert_wpa 'ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev'
    assert_wpa 'country=AU'
    assert_wpa 'update_config=1'
    assert_wpa '  *ssid="foobar"'
    assert_wpa '  *key_mgmt=NONE'
    assert_wpa '  *scan_ssid=1'
    assert_output 'wpa_cli -i wlan0 reconfigure'
}

@test "set_wifi() with network name, passphrase but no country" {
    export -f wpa_cli
    INI__network__wifi_network='foobar'
    INI__network__wifi_password='P4$Sw0rd'
    unset NI__network__wifi_country
    run set_wifi

    assert_success
    assert_wpa 'ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev'
    refute_wpa 'country='
    assert_wpa 'update_config=1'
    assert_wpa '  *ssid="foobar"'
    assert_wpa '  *psk="P4$Sw0rd"'
    assert_wpa '  *scan_ssid=1'
    assert_output 'wpa_cli -i wlan0 reconfigure'
}

@test "set_wifi() with network name, passphrase and country" {
    export -f wpa_cli
    INI__network__wifi_network='foobar'
    INI__network__wifi_password='P4$Sw0rd'
    INI__network__wifi_country=AU
    run set_wifi

    assert_success
    assert_wpa 'ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev'
    assert_wpa 'country=AU'
    assert_wpa 'update_config=1'
    assert_wpa '  *ssid="foobar"'
    assert_wpa '  *psk="P4$Sw0rd"'
    assert_wpa '  *scan_ssid=1'
    assert_output 'wpa_cli -i wlan0 reconfigure'
}

@test "set_wifi() with network name, psk but no country" {
    export -f wpa_cli
    INI__network__wifi_network='foobar'
    INI__network__wifi_password='2af0a6dadc015bf89ecaf495678e7cbc8f9f98f4fe1c17b1cccb258e6d443814'
    unset NI__network__wifi_country
    run set_wifi

    assert_success
    assert_wpa 'ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev'
    refute_wpa 'country='
    assert_wpa 'update_config=1'
    assert_wpa '  *ssid="foobar"'
    assert_wpa '  *psk=2af0a6dadc015bf89ecaf495678e7cbc8f9f98f4fe1c17b1cccb258e6d443814'
    assert_wpa '  *scan_ssid=1'
    assert_output 'wpa_cli -i wlan0 reconfigure'
}

@test "set_wifi() with network name, psk and country" {
    export -f wpa_cli
    INI__network__wifi_network='foobar'
    INI__network__wifi_password='2af0a6dadc015bf89ecaf495678e7cbc8f9f98f4fe1c17b1cccb258e6d443814'
    INI__network__wifi_country=AU
    run set_wifi

    assert_success
    assert_wpa 'ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev'
    assert_wpa 'country=AU'
    assert_wpa 'update_config=1'
    assert_wpa '  *ssid="foobar"'
    assert_wpa '  *psk=2af0a6dadc015bf89ecaf495678e7cbc8f9f98f4fe1c17b1cccb258e6d443814'
    assert_wpa '  *scan_ssid=1'
    assert_output 'wpa_cli -i wlan0 reconfigure'
}
