#!/bin/sh

command -v flock >/dev/null 2>&1 || exit 1

exec 9>/tmp/battery-monitor.lock
flock -n 9 || exit 0

BAT_PATH="/sys/class/power_supply/BAT0"
[ -d "$BAT_PATH" ] || exit 1

low=20
critical=15
backupTime=25
sleepTime=60
criticalAction="suspend"
notified=0

while true; do
    battery=$(cat "$BAT_PATH/capacity")
    state=$(cat "$BAT_PATH/status")

    if [ "$state" = "Discharging" ]; then
        if [ "$battery" -gt "$critical" ] && [ "$battery" -le "$low" ] && [ "$notified" -eq 0 ]; then
            notify-send -r 9001 \
                "Battery Low ($battery%)" \
                "Plug in charger soon" \
                --icon=battery-low
            notified=1
        fi

        if [ "$battery" -le "$critical" ] && [ "$notified" -ne 2 ]; then
            expire=$((backupTime * 1000))

            notify-send -r 9002 \
                "Battery Critical ($battery%)" \
                "System will $criticalAction in $backupTime seconds" \
                --urgency=critical \
                --icon=battery-caution \
                --expire-time="$expire"

            notified=2
            sleep "$backupTime"

            newBattery=$(cat "$BAT_PATH/capacity")
            newState=$(cat "$BAT_PATH/status")

            if [ "$newState" = "Discharging" ] && [ "$newBattery" -le "$critical" ]; then
                logger "battery-monitor: battery critical at ${newBattery}%, running ${criticalAction}"
                systemctl "$criticalAction"
            else
                notified=0
            fi
        fi
    else
        notified=0
    fi

    sleep "$sleepTime"
done