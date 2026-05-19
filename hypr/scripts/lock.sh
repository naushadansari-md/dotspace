#!/usr/bin/env bash
set -Eeuo pipefail

# Use 1440x900 for MBA 2017 to save CPU cycles during processing
RES="1440x900"
BLUR="$HOME/.cache/blurred_wallpaper.png"
WALL_DIR="$HOME/.config/hypr/wallpapers"

have() { command -v "$1" >/dev/null 2>&1; }

# 1. IMMEDIATE HARDWARE ACTION
# Turn off keyboard backlight instantly before doing any heavy image processing
if have brightnessctl; then
    brightnessctl -d "smc::kbd_backlight" set 0
fi

# 2. OPTIMIZED BLUR GENERATION
if [[ ! -s "$BLUR" ]]; then
    mkdir -p "$(dirname "$BLUR")"
    
    # Get current wallpaper efficiently
    CURRENT=""
    if have swww; then
        CURRENT=$(swww query | awk -F 'image: ' '{print $2}' | head -n1)
    fi

    # Fallback to random if swww query fails
    if [[ -z "$CURRENT" || ! -f "$CURRENT" ]]; then
        CURRENT=$(find "$WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" \) | shuf -n1)
    fi

    if [[ -n "$CURRENT" && -f "$CURRENT" ]] && have magick; then
        # OPTIMIZATION: Downscale BEFORE blurring. 
        # Blurring a small image and then scaling up is 10x faster and looks identical.
        magick "$CURRENT" \
            -resize 25% \
            -blur 0x5 \
            -resize "$RES!" \
            "$BLUR"
    else
        [[ -n "$CURRENT" && -f "$CURRENT" ]] && cp -f "$CURRENT" "$BLUR"
    fi
fi

# 3. EXECUTE LOCK
# Using 'exec' replaces the shell process with hyprlock, saving RAM.
exec hyprlock