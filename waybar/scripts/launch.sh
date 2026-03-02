#!/usr/bin/env sh
# ~/.config/waybar/scripts/launch.sh

set -eu

# Avoid duplicate bars
pkill -x waybar 2>/dev/null || true

# Give compositor time to start
sleep 1

# If waybar is not available, do nothing
command -v waybar >/dev/null 2>&1 || exit 0

# Hyprland (env var is the most reliable)
if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] \
  || pgrep -x Hyprland >/dev/null 2>&1 \
  || pgrep -x hyprland >/dev/null 2>&1; then
  exec waybar -c "$HOME/.config/waybar/config-hypr.jsonc"
fi

# Niri
if pgrep -x niri >/dev/null 2>&1; then
  exec waybar -c "$HOME/.config/waybar/config-niri.jsonc"
fi

# Fallback (should rarely be used)
exec waybar
