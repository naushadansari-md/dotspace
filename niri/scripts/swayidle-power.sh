#!/bin/sh
set -eu

WARN="$HOME/.config/niri/lock-warning.sh"

# ----- Customize your timeouts here (seconds) -----
# On AC:
AC_WARN=595
AC_LOCK=600
AC_OFF=900

# On battery:
BAT_WARN=295
BAT_LOCK=300
BAT_OFF=420
# -----------------------------------------------

get_ac_online() {
  for d in /sys/class/power_supply/*; do
    [ -r "$d/type" ] || continue
    if [ "$(cat "$d/type")" = "Mains" ] && [ -r "$d/online" ]; then
      cat "$d/online"
      return 0
    fi
  done
  echo 0
}

# Extract output names like eDP-1, HDMI-A-1 from lines:
# Output "..." (eDP-1)
get_outputs() {
  niri msg outputs 2>/dev/null | sed -n 's/^Output .* (\([^)]\+\)).*$/\1/p'
}

outputs_off() {
  get_outputs | while IFS= read -r o; do
    [ -n "$o" ] || continue
    niri msg output "$o" off >/dev/null 2>&1 || true
  done
}

outputs_on() {
  get_outputs | while IFS= read -r o; do
    [ -n "$o" ] || continue
    niri msg output "$o" on >/dev/null 2>&1 || true
  done
}

start_swayidle() {
  mode="$1" # AC or BAT
  if [ "$mode" = "AC" ]; then
    WARN_T="$AC_WARN"; LOCK_T="$AC_LOCK"; OFF_T="$AC_OFF"
  else
    WARN_T="$BAT_WARN"; LOCK_T="$BAT_LOCK"; OFF_T="$BAT_OFF"
  fi

  echo "Starting swayidle mode=$mode warn=$WARN_T lock=$LOCK_T off=$OFF_T" >&2

  swayidle -w \
    timeout "$WARN_T" "$WARN" \
    timeout "$LOCK_T" 'swaylock -f' \
    timeout "$OFF_T"  'sh -c "$HOME/.config/niri/scripts/swayidle-power.sh --outputs-off"' \
    resume            'sh -c "$HOME/.config/niri/scripts/swayidle-power.sh --outputs-on"' \
    before-sleep      'swaylock -f' &
  echo $!
}

stop_pid() {
  pid="${1:-}"
  [ -n "$pid" ] || return 0
  kill "$pid" 2>/dev/null || true
  wait "$pid" 2>/dev/null || true
}

run_loop() {
  last=""
  pid=""

  trap 'stop_pid "$pid"' INT TERM EXIT

  while :; do
    online="$(get_ac_online)"
    mode="BAT"; [ "$online" = "1" ] && mode="AC"

    if [ "$mode" != "$last" ]; then
      stop_pid "$pid"
      pid="$(start_swayidle "$mode")"
      last="$mode"
    fi

    sleep 2
  done
}

case "${1:-}" in
  --outputs-off) outputs_off; exit 0 ;;
  --outputs-on)  outputs_on;  exit 0 ;;
esac

run_loop