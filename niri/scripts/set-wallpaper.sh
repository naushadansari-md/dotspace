#!/usr/bin/env bash
# ---------------------------------------------------------
# Wallpaper (awww/swww) + matugen (v4+) + waybar
# Non-interactive, script-safe, hyprlock-safe
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
BLUR_OUTPUT="$CACHE_DIR/blurred_wallpaper.png"
BLUR_STAMP="$CACHE_DIR/blurred_wallpaper.stamp"
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

mkdir -p "$CACHE_DIR"

# ----------------------------
# Generate Rasi file (for Rofi)
# ----------------------------
# This creates a theme file you can @import in your rofi config
printf '*{ current-image: url("%s", height); }\n' "$wallpaper" > "$RASI_FILE"

# ----------------------------
# Blur wallpaper (hyprlock safe)
# ----------------------------
need_blur=0
[[ ! -f "$BLUR_OUTPUT" || ! -f "$BLUR_STAMP" ]] && need_blur=1
[[ "$(cat "$BLUR_STAMP" 2>/dev/null)" != "$wallpaper" ]] && need_blur=1

im=""
have magick && im="magick"
have convert && [[ -z "$im" ]] && im="convert"

if [[ "$need_blur" -eq 1 ]]; then
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
  echo "$wallpaper" > "$BLUR_STAMP"
fi

# ----------------------------
# Set wallpaper
# ----------------------------
if [[ -n "$WALL_CMD" ]]; then
  if ! "$WALL_CMD" query >/dev/null 2>&1; then
    pkill -x "${WALL_CMD}-daemon" 2>/dev/null || true
    "$WALL_CMD" init >/dev/null 2>&1 || true
    sleep 0.2
  fi
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