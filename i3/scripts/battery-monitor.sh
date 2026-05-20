#!/bin/sh

# Exit immediately if a command fails unexpectedly
set -e

# =====================================================================
# CONFIGURATION thresholds
# =====================================================================
low=20
critical=15

# Time allocations (seconds)
backupTime=25
sleepTime=60

# Operational Directives (suspend, poweroff, hibernate, hybrid-sleep)
criticalAction="suspend"

# State Tracker (POSIX safe integer assignment)
notified=0

# =====================================================================
# MAIN MONITORING LOOP
# =====================================================================
while true ; do
    # Verify battery interface exists to prevent silent loops on system changes
    if [ ! -d "/sys/class/power_supply/BAT0" ]; then
        echo "Error: BAT0 directory not found. Exiting tracker." >&2
        exit 1
    fi

    # Read system hardware states safely
    battery=$(cat /sys/class/power_supply/BAT0/capacity)
    state=$(cat /sys/class/power_supply/BAT0/status)

    if [ "$state" = "Discharging" ] ; then
        
        # --- Condition A: Low Battery Alert ---
        if [ "$battery" -gt "$critical" ] && [ "$battery" -le "$low" ] && [ "$notified" -eq 0 ] ; then        
            notify-send 'Battery Low' 'Plugin to Recharge' --icon=battery-low
            notified=1  # Fixed bashism
            
        # --- Condition B: Critical Battery Alert & Countdown ---
        elif [ "$battery" -le "$critical" ] ; then
            tempTime=$(( backupTime * 1000 ))
            notify-send "Turning off system in $backupTime sec(s)" \
                        "Backup Data or Plugin to Recharge" \
                        --icon=battery-low \
                        --urgency=critical \
                        --expire-time=$tempTime
            
            sleep "$backupTime"
            
            # Re-verify power status after countdown
            tempState=$(cat /sys/class/power_supply/BAT0/status)
            if [ "$tempState" = "Discharging" ] ; then
                systemctl "$criticalAction"
            else
                notified=0  # Fixed bashism
            fi      
        fi
    else
        # Reset alert flag if plugged into AC wall power
        notified=0  # Fixed bashism
    fi
    
    sleep "$sleepTime"
done