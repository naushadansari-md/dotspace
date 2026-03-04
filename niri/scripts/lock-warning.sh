#!/bin/sh

APP="idle-warning"

notify-send \
  -a "$APP" \
  -u critical \
  -i preferences-desktop-screensaver \
  -t 5000 \
  "Screen locking soon" \
  "Move the mouse or press a key to stay unlocked."