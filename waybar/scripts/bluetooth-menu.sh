#!/usr/bin/env bash

ROFI="rofi -dmenu -i -markup-rows -p Bluetooth -theme /home/saad/.config/rofi/rofi-menu.rasi"
BLUETOOTHCTL="/usr/bin/bluetoothctl"
NOTIFY="/usr/bin/notify-send"

bt_power="$($BLUETOOTHCTL show | awk -F': ' '/Powered:/ {print $2}')"
connected_name="$($BLUETOOTHCTL devices Connected | sed 's/^Device [^ ]* //; q')"

notify() {
    $NOTIFY "Bluetooth" "$1"
}

ensure_powered() {
    if [ "$bt_power" != "yes" ]; then
        $BLUETOOTHCTL power on >/dev/null
        bt_power="yes"
    fi
}

build_menu() {
    if [ "$bt_power" = "yes" ]; then
        echo "<b>󰂯  Bluetooth: On</b>"
    else
        echo "󰂲  Bluetooth: Off"
    fi

    if [ -n "$connected_name" ]; then
        printf "<b>󰂱  Connected: %s</b>\n" "$connected_name"
    else
        echo "󰂲  Connected: None"
    fi

    echo "󰐥  Toggle Bluetooth"
    echo "󰑐  Scan"
    echo "󰌾  Pairable On"
    echo "󰌿  Pairable Off"
    echo "󰕾  Disconnect"
    echo '<span foreground="#666666">──────────────────</span>'

    {
        $BLUETOOTHCTL devices Paired
        $BLUETOOTHCTL devices
    } | awk '
    /^Device / {
        mac = $2
        name = substr($0, index($0, $3))

        if (seen[mac]++) next

        cmd = "bluetoothctl info " mac
        paired = 0
        connected = 0

        while ((cmd | getline line) > 0) {
            if (line ~ /Paired: yes/) paired = 1
            if (line ~ /Connected: yes/) connected = 1
        }
        close(cmd)

        if (connected) {
            icon = "󰂱"
            printf "<b>󰸞  %s  %s</b>\n", name, icon
        } else if (paired) {
            icon = "󰂯"
            printf "%s  %s\n", name, icon
        } else {
            icon = "󰂰"
            printf "%s  %s\n", name, icon
        }
    }'
}

chosen="$(build_menu | eval "$ROFI")"

case "$chosen" in
    "<b>󰂯  Bluetooth: On</b>"|"󰂲  Bluetooth: Off"|"---"|""|"<b>󰂱  Connected: "*|"󰂲  Connected: None")
        exit 0
        ;;
    "󰐥  Toggle Bluetooth")
        if [ "$bt_power" = "yes" ]; then
            $BLUETOOTHCTL power off >/dev/null && notify "Bluetooth Disabled"
        else
            $BLUETOOTHCTL power on >/dev/null && notify "Bluetooth Enabled"
        fi
        ;;
    "󰑐  Scan")
        ensure_powered
        $BLUETOOTHCTL scan on >/dev/null &
        notify "Bluetooth scan started"
        ;;
    "󰌾  Pairable On")
        ensure_powered
        $BLUETOOTHCTL pairable on >/dev/null && notify "Pairable enabled"
        ;;
    "󰌿  Pairable Off")
        $BLUETOOTHCTL pairable off >/dev/null && notify "Pairable disabled"
        ;;
    "󰕾  Disconnect")
        if [ -n "$connected_name" ]; then
            mac="$($BLUETOOTHCTL devices Connected | awk 'NR==1{print $2}')"
            [ -n "$mac" ] && $BLUETOOTHCTL disconnect "$mac" >/dev/null && notify "Disconnected"
        else
            notify "No connected device"
        fi
        ;;
    *)
        clean="$(printf '%s' "$chosen" | sed 's/<[^>]*>//g' | sed 's/^󰸞  //')"
        name="$(printf '%s' "$clean" | sed 's/  󰂱$//; s/  󰂯$//; s/  󰂰$//')"

        [ -z "$name" ] && exit 0

        ensure_powered

        mac="$($BLUETOOTHCTL devices | sed -n "s/^Device \([^ ]*\) ${name}$/\1/p" | head -n1)"
        [ -z "$mac" ] && mac="$($BLUETOOTHCTL devices Paired | sed -n "s/^Device \([^ ]*\) ${name}$/\1/p" | head -n1)"
        [ -z "$mac" ] && {
            notify "Device not found"
            exit 1
        }

        info="$($BLUETOOTHCTL info "$mac" 2>/dev/null)"
        is_paired="$(printf '%s\n' "$info" | awk -F': ' '/Paired:/ {print $2; exit}')"
        is_connected="$(printf '%s\n' "$info" | awk -F': ' '/Connected:/ {print $2; exit}')"

        if [ "$is_connected" = "yes" ]; then
            $BLUETOOTHCTL disconnect "$mac" >/dev/null \
                && notify "Disconnected from $name" \
                || notify "Failed to disconnect $name"
        else
            if [ "$is_paired" != "yes" ]; then
                $BLUETOOTHCTL pair "$mac" >/dev/null || {
                    notify "Pairing failed for $name"
                    exit 1
                }
            fi

            $BLUETOOTHCTL connect "$mac" >/dev/null \
                && notify "Connected to $name" \
                || notify "Failed to connect $name"
        fi
        ;;
esac