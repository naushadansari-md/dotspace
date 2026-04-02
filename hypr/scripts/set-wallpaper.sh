#!/usr/bin/env bash
# ---------------------------------------------------------
# Wallpaper (awww/swww) + matugen (v4+) + waybar + dock
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
WALLPAPERS_DIR="$HOME/.config/hypr/wallpapers"
DOCK_SCRIPT="$HOME/.config/hypr/scripts/start-dock.sh"

CACHE_DIR="$HOME/.cache"
BLUR_OUTPUT="$CACHE_DIR/blurred_wallpaper.png"
BLUR_STAMP="$CACHE_DIR/blurred_wallpaper.stamp"
RES="1920x1080"

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

mkdir -p "$CACHE_DIR"

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