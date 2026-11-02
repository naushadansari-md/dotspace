#!/usr/bin/env bash
# ---------------------------------------------------------
# Wallpaper (awww/swww) + matugen (v4+) + waybar
# Optimized with per-wallpaper caching for instant switching
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
WALLPAPERS_DIR="$HOME/.config/niri/wallpapers"
CACHE_DIR="$HOME/.cache"
BLUR_CACHE_DIR="$CACHE_DIR/blurred_wallpapers"
RASI_FILE="$CACHE_DIR/current_wallpaper.rasi"
RES="1920x1080"

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
# Pick random wallpaper
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

mkdir -p "$CACHE_DIR" "$BLUR_CACHE_DIR"

# ----------------------------
# Generate Rasi file (for Rofi)
# ----------------------------
printf '*{ current-image: url("%s", height); }\n' "$wallpaper" > "$RASI_FILE"

# ----------------------------
# Blur wallpaper (Per-wallpaper cache)
# ----------------------------
# Generate a unique hash for the wallpaper path to use as cache key
wall_hash="$(printf '%s' "$wallpaper" | sha256sum | cut -d' ' -f1)"
BLUR_OUTPUT="$BLUR_CACHE_DIR/${wall_hash}.png"

im=""
have magick && im="magick"
have convert && [[ -z "$im" ]] && im="convert"

if [[ ! -f "$BLUR_OUTPUT" ]]; then
  if [[ -n "$im" ]]; then
    "$im" "$wallpaper" \
      -strip \
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
# Set wallpaper
# ----------------------------
if [[ -n "$WALL_CMD" ]]; then
  # Check if awww-daemon is already running; start detached if missing
  if ! pgrep -x "${WALL_CMD}-daemon" >/dev/null 2>&1; then
    nohup "${WALL_CMD}-daemon" >/dev/null 2>&1 &
    sleep 0.3
  fi

  # Apply wallpaper without killing existing daemon
  "$WALL_CMD" img "$wallpaper" >/dev/null 2>&1 || true
fi

# ----------------------------
# Matugen (v4+)
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

log "DONE"
