#!/usr/bin/env bash

ROFI_THEME="/home/saad/.config/rofi/rofi-menu.rasi"
ROFI="/usr/bin/rofi"
NMCLI="/usr/bin/nmcli"
NOTIFY="/usr/bin/notify-send"

CACHE_FILE="/tmp/rofi-wifi-cache"
STATE_FILE="/tmp/rofi-wifi-state"
SAVED_FILE="/tmp/rofi-wifi-saved"

# Auto-cleanup leftover temp cache files
find /tmp -maxdepth 1 -type f \( -name 'rofi-wifi-cache.*' -o -name 'rofi-wifi-saved.*' \) -delete 2>/dev/null

ROFI_MENU=("$ROFI" -dmenu -i -markup-rows -p "Network" -theme "$ROFI_THEME")
ROFI_PASS=("$ROFI" -dmenu -password -p "Password" -theme "$ROFI_THEME")
ROFI_INPUT=("$ROFI" -dmenu -i -p "Network" -theme "$ROFI_THEME")

notify() {
    "$NOTIFY" "Network" "$1"
}

wifi_if="$("$NMCLI" -t -f DEVICE,TYPE device 2>/dev/null | awk -F: '$2=="wifi"{print $1; exit}')"

[ -z "$wifi_if" ] && {
    notify "No WiFi device found"
    exit 1
}

signal_bar() {
    local s=$1
    if   [ "$s" -ge 80 ]; then echo "▂▄▆█"
    elif [ "$s" -ge 60 ]; then echo "▂▄▆"
    elif [ "$s" -ge 40 ]; then echo "▂▄"
    else echo "▂"
    fi
}

write_state_cache() {
    {
        printf 'WIFI=%s\n' "$("$NMCLI" radio wifi 2>/dev/null)"
        printf 'CURRENT=%s\n' "$("$NMCLI" -t -f ACTIVE,SSID dev wifi list ifname "$wifi_if" 2>/dev/null | awk -F: '$1=="yes"{print $2; exit}')"
    } > "$STATE_FILE"
}

read_state_cache() {
    wifi_state_cached="enabled"
    current_ssid_cached=""

    if [ -s "$STATE_FILE" ]; then
        . "$STATE_FILE"
        [ -n "$WIFI" ] && wifi_state_cached="$WIFI"
        [ -n "$CURRENT" ] && current_ssid_cached="$CURRENT"
    fi
}

write_saved_cache() {
    "$NMCLI" -t -f NAME,TYPE connection show 2>/dev/null \
        | awk -F: '$2=="802-11-wireless"{print $1}' > "$SAVED_FILE"
}

read_saved_cache() {
    unset saved_map
    declare -gA saved_map=()

    [ -s "$SAVED_FILE" ] || return

    while IFS= read -r s; do
        [ -n "$s" ] && saved_map["$s"]=1
    done < "$SAVED_FILE"
}

refresh_all_cache() {
    local tmp
    tmp="$(mktemp /tmp/rofi-wifi-cache.XXXXXX)" || return 1

    if "$NMCLI" -t -f IN-USE,SSID,SECURITY,SIGNAL dev wifi list ifname "$wifi_if" 2>/dev/null > "$tmp"; then
        mv "$tmp" "$CACHE_FILE"
        write_state_cache
        write_saved_cache
        return 0
    fi

    rm -f "$tmp"
    return 1
}

refresh_all_cache_bg() {
    (
        refresh_all_cache
    ) >/dev/null 2>&1 &
}

load_wifi_list() {
    if [ -s "$CACHE_FILE" ]; then
        cat "$CACHE_FILE"
        refresh_all_cache_bg
    else
        refresh_all_cache >/dev/null 2>&1
        cat "$CACHE_FILE" 2>/dev/null
    fi
}

read_state_cache
read_saved_cache
wifi_list="$(load_wifi_list)"

wifi_state="$wifi_state_cached"
current_ssid="$current_ssid_cached"

if [ -z "$current_ssid" ]; then
    current_ssid="$(printf '%s\n' "$wifi_list" | awk -F: '$1=="*"{print $2; exit}')"
fi

build_menu() {

    if [ "$wifi_state" = "enabled" ]; then
        echo "INFO|<b>󰤨  WiFi: On</b>"
    else
        echo "INFO|<b>󰤮  WiFi: Off</b>"
    fi

    if [ -n "$current_ssid" ] && [ "$wifi_state" = "enabled" ]; then
        printf 'INFO|<b>󰤨  Connected: %s</b>\n' "$current_ssid"
    else
        echo "INFO|<b>󰤭  Connected: None</b>"
    fi

    echo "ACTION|󰤭  Toggle WiFi"
    echo "ACTION|󰑐  Scan"
    echo "ACTION|󰖪  Disconnect"
    echo "ACTION|󰛅  Forget Current"
    echo "ACTION|󰛳  Hidden Network"
    echo "SEP|---"

    [ "$wifi_state" = "enabled" ] || return

    printf '%s\n' "$wifi_list" | awk -F: '
    NF>=4 && $2!="" {
        inuse=$1
        ssid=$2
        security=$3
        signal=$4
        if (seen[ssid]++) next
        printf "%s|%s|%s|%s\n", inuse, ssid, security, signal
    }' | while IFS='|' read -r inuse ssid security signal; do

        bars="$(signal_bar "$signal")"

        if [ "$security" = "--" ] || [ -z "$security" ]; then
            lock="󰖩"
        else
            lock="󰌾"
        fi

        if [[ -n "${saved_map[$ssid]}" ]]; then
            star="★"
        else
            star=""
        fi

        if [ "$inuse" = "*" ]; then
            printf 'SSID|%s|<b>✓  %s  %s  %s  %s</b>\n' "$ssid" "$ssid" "$star" "$lock" "$bars"
        else
            printf 'SSID|%s|•  %s  %s  %s  %s\n' "$ssid" "$ssid" "$star" "$lock" "$bars"
        fi
    done
}

menu_input="$(build_menu)"

chosen_display="$(printf '%s\n' "$menu_input" | awk -F'|' '{print $NF}' | "${ROFI_MENU[@]}")"

[ -z "$chosen_display" ] && exit 0

chosen_line="$(printf '%s\n' "$menu_input" | awk -F'|' -v sel="$chosen_display" '$NF==sel {print; exit}')"
entry_type="$(printf '%s\n' "$chosen_line" | cut -d'|' -f1)"

toggle_wifi() {

    state="$("$NMCLI" radio wifi 2>/dev/null)"

    if [ "$state" = "enabled" ]; then
        "$NMCLI" radio wifi off && notify "WiFi turned off"
        echo 'WIFI=disabled' > "$STATE_FILE"
        rm -f "$CACHE_FILE"
    else
        "$NMCLI" radio wifi on && notify "WiFi turned on"
        echo 'WIFI=enabled' > "$STATE_FILE"
        refresh_all_cache_bg
    fi
}

scan_wifi() {
    notify "Scanning WiFi networks..."
    "$NMCLI" device wifi rescan ifname "$wifi_if" >/dev/null 2>&1
    refresh_all_cache_bg
}

disconnect_wifi() {

    [ -z "$current_ssid" ] && {
        notify "No active WiFi connection"
        exit 0
    }

    "$NMCLI" device disconnect "$wifi_if" && notify "Disconnected"

    echo 'CURRENT=' >> "$STATE_FILE"

    refresh_all_cache_bg
}

forget_current_network() {

    [ -z "$current_ssid" ] && {
        notify "No connected network"
        exit 0
    }

    if "$NMCLI" connection delete id "$current_ssid" >/dev/null 2>&1; then
        notify "Forgot $current_ssid"
        echo 'CURRENT=' >> "$STATE_FILE"
    else
        notify "Failed to forget"
    fi

    refresh_all_cache_bg
}

connect_hidden_network() {

    hidden_ssid="$(printf '' | "${ROFI_INPUT[@]}" -p "Hidden SSID")"
    [ -z "$hidden_ssid" ] && exit 0

    password="$("${ROFI_PASS[@]}")"

    (
        "$NMCLI" dev wifi connect "$hidden_ssid" password "$password" hidden yes ifname "$wifi_if" \
            && notify "Connected to $hidden_ssid"

        refresh_all_cache
    ) &
}

case "$entry_type" in

    INFO|SEP)
        exit 0
        ;;

    ACTION)

        action="$(printf '%s\n' "$chosen_line" | cut -d'|' -f2-)"

        case "$action" in

            "󰤭  Toggle WiFi")
                toggle_wifi
                ;;

            "󰑐  Scan")
                scan_wifi
                ;;

            "󰖪  Disconnect")
                disconnect_wifi
                ;;

            "󰛅  Forget Current")
                forget_current_network
                ;;

            "󰛳  Hidden Network")
                connect_hidden_network
                ;;

        esac

        exit 0
        ;;

    SSID)
        ssid="$(printf '%s\n' "$chosen_line" | cut -d'|' -f2)"
        ;;

esac

[ -z "$ssid" ] && exit 0

security="$(printf '%s\n' "$wifi_list" | awk -F: -v s="$ssid" '$2==s {print $3; exit}')"

if [[ -n "${saved_map[$ssid]}" ]]; then

    (
        "$NMCLI" connection up id "$ssid" \
            && notify "Connected to $ssid"

        refresh_all_cache
    ) &

else

    if [ "$security" = "--" ] || [ -z "$security" ]; then

        (
            "$NMCLI" dev wifi connect "$ssid" ifname "$wifi_if" \
                && notify "Connected to $ssid"

            refresh_all_cache
        ) &

    else

        password="$("${ROFI_PASS[@]}")"

        [ -z "$password" ] && exit 0

        (
            "$NMCLI" dev wifi connect "$ssid" password "$password" ifname "$wifi_if" \
                && notify "Connected to $ssid"

            refresh_all_cache
        ) &

    fi
fi