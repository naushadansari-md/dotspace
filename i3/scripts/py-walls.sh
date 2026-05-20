#!/bin/bash

# =====================================================================
# 1. INITIALIZE WALLPAPER & PYWAL
# =====================================================================

# Run pywal to set color scheme and select a random wallpaper
wal -n -i ~/.config/i3/wallpapers/

# Extract the selected wallpaper path from pywal's cache
wallpaper=$(< "${HOME}/.cache/wal/wal")

# Set the background using feh
feh --bg-fill "$wallpaper"


# =====================================================================
# 2. GENERATE BLURRED WALLPAPER & ROFI CONFIG
# =====================================================================

blur="0x8" # Default blur strength. Change to "0x0" for no blur.
wallpaper_filename=$(basename "$wallpaper")
cache_dir="$HOME/.cache/wallpaper_effects"
rasi_file="$HOME/.cache/current_wallpaper.rasi"
blurred_wallpaper="$HOME/.cache/blurred_wallpaper.png"

# Ensure effects cache directory exists
mkdir -p "$cache_dir"

echo ":: Generating cached wallpaper for $wallpaper_filename"

# Resize first to speed up the blur process and save resource usage
magick "$wallpaper" -resize 75% "$blurred_wallpaper"

if [ "$blur" != "0x0" ] ; then
    magick "$blurred_wallpaper" -blur "$blur" "$blurred_wallpaper"
fi

# Save a copy of this specific blurred version to the cache directory
cp "$blurred_wallpaper" "$cache_dir/blur-${blur}-${wallpaper_filename}"

# Update the rasi file for Rofi themes to reference
touch "$rasi_file"
echo "* { current-image: url(\"$blurred_wallpaper\", height); }" > "$rasi_file"


# =====================================================================
# 3. DYNAMICALLY UPDATE CONKY COLORS (The Missing Link!)
# =====================================================================

echo ":: Updating Conky themes..."

template_dir="/usr/share/conky/pywal_conky"
conky_cache_dir="$HOME/.cache/pywal_conky"
conky_rc="$conky_cache_dir/conkyrc"
latest_colors="$conky_cache_dir/latestcolors"

# Ensure local conky cache directory exists
mkdir -p "$conky_cache_dir"

# Kill running conky instances and wait for them to close completely
killall -q conky
while pgrep -u $UID -x conky >/dev/null; do sleep 0.1; done

# Extract first 8 colors from pywal, strip '#' and format for Conky
awk 'NR<=8 {sub(/^#/,""); printf "color%d %s\n", NR, $0}' "$HOME/.cache/wal/colors" > "$latest_colors"

# Merge colors and the structural template safely (No background process race conditions)
if [ -f "$template_dir/conkyseed" ]; then
    cat "$latest_colors" "$template_dir/conkyseed" > "$conky_rc"
    
    # Restart Conky in the background utilizing the freshly baked config
    conky -c "$conky_rc" &> /dev/null &
    notify-send "Theme Updated" "Wallpaper, Rofi, and Conky are synced!"
else
    echo "Warning: conkyseed template not found in $template_dir. Conky not updated." >&2
    notify-send "Theme Partial Update" "Wallpaper changed, but Conky seed was missing."
fi
