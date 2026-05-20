#!/bin/sh

# Get the primary active layout symbol string
current_layout=$(setxkbmap -query | awk '/layout:/ {print $2}')

# Toggle between layout matrices
if [ "$current_layout" = "us" ]; then
    # Switch to Canadian layout with French secondary rules
    setxkbmap ca
    
    # Optional: If you want both layouts active with a hardware toggle, use:
    # setxkbmap -layout ca,fr -option grp:alt_shift_toggle
    
    notify-send "Keyboard Layout Changed" "Active: Canadian (CA)" --icon=input-keyboard --expire-time=2000
else
    # Switch back to standard US English layout
    setxkbmap us -option ""
    notify-send "Keyboard Layout Changed" "Active: English (US)" --icon=input-keyboard --expire-time=2000
fi

# Ensure key-repeat metrics (like CapLocks/mod alterations) stay applied uniformly
xset -r 66