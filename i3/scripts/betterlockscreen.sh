#!/bin/sh

set -e

# Define explicit paths to prevent symlink expansion failure
WAL_RC="$HOME/.cache/wal/betterlockscreenrc"
TARGET_DIR="$HOME/.config/betterlockscreen"
TARGET_RC="$TARGET_DIR/betterlockscreenrc"

# 1. Ensure the destination directory exists
mkdir -p "$TARGET_DIR"

# 2. Symlink the Pywal resource configuration safely
if [ -f "$WAL_RC" ]; then
    ln -sf "$WAL_RC" "$TARGET_RC"
fi

# 3. Regenerate the lockscreen image cache with the new wallpaper & colors
# We pull the current wallpaper path from your .fehbg file automatically
if [ -f "$HOME/.fehbg" ]; then
    WALLPAPER=$(grep -o "'.*'" "$HOME/.fehbg" | head -n 1 | tr -d "'")
    
    if [ -f "$WALLPAPER" ]; then
        # Updates the background cache in the background cleanly without freezing i3
        betterlockscreen -u "$WALLPAPER" --fx dim,blur > /dev/null 2>&1 &
    fi
fi