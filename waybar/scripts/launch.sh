#!/usr/bin/env sh
# ~/.config/waybar/scripts/launch.sh

set -eu

# If waybar is not available, do nothing
command -v waybar >/dev/null 2>&1 || exit 0

# Single-instance guard (prevents double-start races)
LOCK="${XDG_RUNTIME_DIR:-/tmp}/waybar-launch.lock"
exec 9>"$LOCK"
flock -n 9 || exit 0

# Avoid duplicate bars (user session only)
pkill -u "$USER" -x waybar 2>/dev/null || true

# Wait for waybar to fully exit (prevents “pkill then immediately restart twice”)
i=0
while pgrep -u "$USER" -x waybar >/dev/null 2>&1; do
  i=$((i+1))
  [ "$i" -gt 50 ] && break   # ~5s max
  sleep 0.1
done

# Give compositor time to settle
sleep 0.2

# Hyprland
if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] \
  || pgrep -x Hyprland >/dev/null 2>&1 \
  || pgrep -x hyprland >/dev/null 2>&1; then
  exec waybar -c "$HOME/.config/waybar/config-hypr.jsonc"
fi

# Niri
if pgrep -x niri >/dev/null 2>&1; then
  exec waybar -c "$HOME/.config/waybar/config-niri.jsonc"
fi

# Fallback
exec waybar