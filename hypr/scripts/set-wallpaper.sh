#!/usr/bin/env bash
# ---------------------------------------------------------
# Wallpaper (awww/swww) + matugen (v4+) + waybar + dock + rofi rasi
# Non-interactive, script-safe, hyprlock-safe (Optimized Cache)
# ---------------------------------------------------------

set -Eeuo pipefail

# ----------------------------
# Wayland environment
# ----------------------------
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

if [[ -z "${WAYLAND_DISPLAY:-}" ]]; then
  for sock in "$XDG_RUNTIME_DIR"/wayland-*; do
    [[ -S "$sock" ]] && export WAYLAND_DISPLAY="$(basename "$sock")" && break
  done
fi

# ----------------------------
# Config
# ----------------------------
WALLPAPERS_DIR="$HOME/.config/hypr/wallpapers"
DOCK_SCRIPT="$HOME/.config/hypr/scripts/start-dock.sh"

CACHE_DIR="$HOME/.cache"
BLUR_CACHE_DIR="$CACHE_DIR/blurred_wallpapers"
RASI_FILE="$CACHE_DIR/current_wallpaper.rasi"
RES="1440x900"

SWWW_TRANSITION="none"
SWWW_DURATION="0"

# ----------------------------
# Helpers
# ----------------------------
have() { command -v "$1" >/dev/null 2>&1; }
log() { printf '%s\n' "$*"; }
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }

# ----------------------------
# Detect wallpaper backend
# ----------------------------
WALL_CMD=""
have awww && WALL_CMD="awww"
have swww && [[ -z "$WALL_CMD" ]] && WALL_CMD="swww"

# ----------------------------
# Pick random wallpaper (null-safe)
# ----------------------------
pick_random() {
  find "$WALLPAPERS_DIR" -type f \
    \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.webp" \) \
    -print0 | shuf -z -n 1 | tr -d '\0'
}

wallpaper="${1:-}"
[[ -z "$wallpaper" ]] && wallpaper="$(pick_random)"

[[ -f "$wallpaper" ]] || fail "Wallpaper not found"
log "Wallpaper: $wallpaper"
log "Backend: ${WALL_CMD:-none}"

mkdir -p "$CACHE_DIR" "$BLUR_CACHE_DIR"

# ----------------------------
# Generate Rasi file (for Rofi)
# ----------------------------
printf '*{ current-image: url("%s", height); }\n' "$wallpaper" > "$RASI_FILE"

# ----------------------------
# Blur wallpaper (Per-wallpaper cache)
# ----------------------------
wall_hash="$(printf '%s' "$wallpaper" | sha256sum | cut -d' ' -f1)"
BLUR_OUTPUT="$BLUR_CACHE_DIR/${wall_hash}.png"

im=""
have magick && im="magick"
have convert && [[ -z "$im" ]] && im="convert"

if [[ ! -f "$BLUR_OUTPUT" ]]; then
  if [[ -n "$im" ]]; then
    "$im" "$wallpaper" \
      -resize "${RES}^" \
      -gravity center \
      -extent "$RES" \
      -blur 0x20 \
      "$BLUR_OUTPUT" || cp "$wallpaper" "$BLUR_OUTPUT"
  else
    cp "$wallpaper" "$BLUR_OUTPUT"
  fi
fi

# ----------------------------
# Set wallpaper (Robust Daemon Check)
# ----------------------------
if [[ -n "$WALL_CMD" ]]; then
  DAEMON_NAME="${WALL_CMD}-daemon"
  
  if ! pgrep -x "$DAEMON_NAME" >/dev/null 2>&1; then
    nohup "$DAEMON_NAME" >/dev/null 2>&1 &
    sleep 0.5
  fi

  # Apply wallpaper supporting swww transition flags safely
  if [[ "$WALL_CMD" == "swww" ]]; then
    swww img "$wallpaper" --transition-type "$SWWW_TRANSITION" --transition-duration "$SWWW_DURATION" >/dev/null 2>&1 || true
  else
    "$WALL_CMD" img "$wallpaper" >/dev/null 2>&1 || true
  fi
fi

# ----------------------------
# Matugen (FIXED for v4+)
# ----------------------------
if have matugen; then
  matugen image "$wallpaper" \
    -t scheme-tonal-spot \
    --mode dark \
    --source-color-index 0 \
    --quiet || true
fi

# ----------------------------
# Reload Waybar
# ----------------------------
if have waybar; then
  if pgrep -x waybar >/dev/null; then
    pkill -SIGUSR2 waybar
  else
    waybar >/dev/null 2>&1 &
  fi
fi

# ----------------------------
# Restart Dock (nwg-dock-hyprland)
# ----------------------------
sleep 1

killall nwg-dock-hyprland 2>/dev/null || true
sleep 0.3

[[ -x "$DOCK_SCRIPT" ]] && "$DOCK_SCRIPT" &
log "DONE"