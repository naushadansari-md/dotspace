#!/usr/bin/env bash

STATE_FILE="/tmp/waybar-network-toggle"

# toggle mode on click
if [[ "$1" == "toggle" ]]; then
    if [[ -f "$STATE_FILE" ]]; then
        rm -f "$STATE_FILE"
    else
        touch "$STATE_FILE"
    fi

    # refresh waybar immediately
    pkill -RTMIN+8 waybar
    exit 0
fi

# detect active connection
WIFI_DEV=$(nmcli -t -f DEVICE,TYPE,STATE device | awk -F: '$2=="wifi" && $3=="connected" {print $1; exit}')
ETH_DEV=$(nmcli -t -f DEVICE,TYPE,STATE device | awk -F: '$2=="ethernet" && $3=="connected" {print $1; exit}')

if [[ -n "$WIFI_DEV" ]]; then
    SIGNAL=$(nmcli -t -f IN-USE,SIGNAL dev wifi | awk -F: '$1=="*" {print $2; exit}')
    ICON=""
    TOOLTIP="WiFi ${SIGNAL}%"

    if [[ -f "$STATE_FILE" ]]; then
        TEXT="$ICON ${SIGNAL}%"
    else
        TEXT="$ICON"
    fi

elif [[ -n "$ETH_DEV" ]]; then
    ICON="󰈀"
    TOOLTIP="Ethernet ${ETH_DEV}"

    if [[ -f "$STATE_FILE" ]]; then
        TEXT="$ICON"
    else
        TEXT="$ICON"
    fi

else
    ICON="󰖪"
    TOOLTIP="Disconnected"
    TEXT="$ICON"
fi

printf '{"text":"%s","tooltip":"%s"}\n' "$TEXT" "$TOOLTIP"