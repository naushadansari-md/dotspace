#!/usr/bin/env bash

mkdir -p ~/Pictures/Screenshots
FILE=~/Pictures/Screenshots/Screenshot-$(date +%F_%T).png

case "$1" in
  full)
    grim - | tee "$FILE" | wl-copy
    ;;
  area)
    grim -g "$(slurp)" - | tee "$FILE" | wl-copy
    ;;
  edit)
    grim -g "$(slurp)" - | swappy -f -
    exit 0
    ;;
esac

if [ -s "$FILE" ]; then
  notify-send -i "$FILE" "Screenshot" "Captured" -t 1000
else
  rm -f "$FILE"
fi
