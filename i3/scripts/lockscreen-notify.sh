#!/bin/sh

set -e

# Automatically detect and export the DBUS session address if it's missing
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    PID=$(pgrep -u "$USER" i3 | head -n 1)
    export DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/"$PID"/environ | cut -d= -f2-)
fi

notify-send --urgency=critical \
            --icon=preferences-desktop-screensaver \
            --expire-time=5000 \
            "About to lock screen..." \
            "Move mouse or use corners to abort"