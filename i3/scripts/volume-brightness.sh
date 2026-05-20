#!/bin/bash

# Configuration settings
volume_step=5
brightness_step=2
max_volume=100
notification_timeout=1000

# =====================================================================
# SYSTEM HARDWARE VALUE FETCHERS
# =====================================================================

get_volume() {
    pulsemixer --get-volume | awk '{print $1}'
}

get_mute() {
    pulsemixer --get-mute
}

get_brightness() {
    brightnessctl get
}

# =====================================================================
# DESKTOP NOTIFICATION ICON GENERATORS
# =====================================================================

get_volume_icon() {
    local volume
    local mute
    volume=$(get_volume)
    mute=$(get_mute)
    
    if [ "$volume" -eq 0 ] || [ "$mute" -eq 1 ]; then
        volume_icon="󰕿"  # Mute icon
    elif [ "$volume" -lt 50 ]; then
        volume_icon="󰖀"  # Low volume icon
    else
        volume_icon="󰕾"  # High volume icon
    fi
}

get_brightness_icon() {
    brightness_icon="󰃠"
}

# =====================================================================
# DUNST STATUS RENDERING PIPELINES
# =====================================================================

show_volume_notif() {
    local volume
    volume=$(get_volume)
    get_volume_icon
    notify-send -t $notification_timeout \
                -h string:x-dunst-stack-tag:volume_notif \
                -h int:value:"$volume" \
                "$volume_icon    $volume%"
}

show_brightness_notif() {
    local brightness
    local max_brightness
    local percentage
    brightness=$(get_brightness)
    max_brightness=$(brightnessctl max)
    percentage=$(( brightness * 100 / max_brightness ))
    get_brightness_icon
    notify-send -t $notification_timeout \
                -h string:x-dunst-stack-tag:brightness_notif \
                -h int:value:"$percentage" \
                "$brightness_icon    $percentage%"
}

# =====================================================================
# SYSTEM EVENT HANDLER SWITCHWAY
# =====================================================================

case $1 in
    volume_up)
        # Unmute automatically when raising volume
        pulsemixer --toggle-mute 0
        pulsemixer --change-volume +"$volume_step" --max-volume "$max_volume"
        show_volume_notif
        ;;

    volume_down)
        # Adjust volume downward cleanly without forced unmute triggers
        pulsemixer --change-volume -"$volume_step" --max-volume "$max_volume"
        show_volume_notif
        ;;

    volume_mute)
        # Safely toggle mute flags via a singular driver API
        pulsemixer --toggle-mute
        show_volume_notif
        ;;

    brightness_up)
        brightnessctl set +"$brightness_step"%
        show_brightness_notif
        ;;

    brightness_down)
        brightnessctl set "$brightness_step"%-
        show_brightness_notif
        ;;
    
    *)
        notify-send "Error" "Invalid argument. Use 'volume_up', 'volume_down', 'brightness_up', or 'brightness_down'."
        ;;
esac