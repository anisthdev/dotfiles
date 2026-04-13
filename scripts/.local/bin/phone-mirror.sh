#!/bin/bash

# Config - update these for your setup
HOTSPOT_NAME="Pixel_6A"
ADB_PATH="/home/asif/.sdks/android/platform-tools/adb"
GATEWAY_IP="10.171.135.99"
ADB_PORT="5555"
ICON_WIFI="network-wireless"
ICON_PHONE="phone"
ICON_ERROR="error"

# Check if connected to hotspot
if ! nmcli -t -f NAME,TYPE con show --active | grep -q "^${HOTSPOT_NAME}:802-11-wireless"; then
    notify-send -u critical -a "Phone Mirror" "Not connected to ${HOTSPOT_NAME}"
    exit 1
fi

# Helper: check if device is online (authorized)
is_device_online() {
    $ADB_PATH devices | grep -q "${GATEWAY_IP}:${ADB_PORT}.*device$"
}

# If device is offline, disconnect and reconnect to force a fresh handshake
if $ADB_PATH devices | grep -q "${GATEWAY_IP}:${ADB_PORT}.*offline"; then
    notify-send -u normal -a "Phone Mirror" "ADB device offline — reconnecting…"
    $ADB_PATH disconnect "${GATEWAY_IP}:${ADB_PORT}"
    sleep 0.5
fi

# Connect if not already online
if ! is_device_online; then
    $ADB_PATH connect "${GATEWAY_IP}:${ADB_PORT}"
fi

# Verify connection
sleep 0.5
if ! is_device_online; then
    notify-send -u critical -a "Phone Mirror" "Failed to connect via ADB.\nDevice may be offline or USB debugging not enabled."
    exit 1
fi

scrcpy
