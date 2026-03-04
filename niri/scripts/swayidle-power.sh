#!/bin/sh
set -eu

WARN="$HOME/.config/niri/scripts/lock-warning.sh"

# On AC:
AC_WARN=595
AC_LOCK=600
AC_OFF=900

# On battery:
BAT_WARN=295
BAT_LOCK=300
BAT_OFF=420

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

mode_now() {
  [ "$(get_ac_online)" = "1" ] && echo "AC" || echo "BAT"
}

lock_cmd='pgrep -x hyprlock >/dev/null 2>&1 || hyprlock --immediate-render --no-fade-in'

start_swayidle() {
  mode="$1"
  if [ "$mode" = "AC" ]; then
    WARN_T="$AC_WARN"; LOCK_T="$AC_LOCK"; OFF_T="$AC_OFF"
  else
    WARN_T="$BAT_WARN"; LOCK_T="$BAT_LOCK"; OFF_T="$BAT_OFF"
  fi

  # Ensure ordering: warn < lock < off
  if [ "$OFF_T" -le "$LOCK_T" ]; then
    OFF_T=$((LOCK_T + 1))
  fi
  if [ "$LOCK_T" -le "$WARN_T" ]; then
    WARN_T=$((LOCK_T > 5 ? LOCK_T - 5 : LOCK_T - 1))
  fi

  echo "Starting swayidle mode=$mode warn=$WARN_T lock=$LOCK_T off=$OFF_T" >&2

  exec swayidle -w \
    timeout "$WARN_T" "$WARN" \
    timeout "$LOCK_T"  "$lock_cmd" \
    timeout "$OFF_T"   'niri msg action power-off-monitors' \
    resume             'niri msg action power-on-monitors' \
    before-sleep       "$lock_cmd"
}

run() {
  last="$(mode_now)"
  pid=""
  monpid=""

  fifo="/tmp/swayidle-power.$UID.fifo"

  cleanup() {
    [ -n "${pid:-}" ] && { kill "$pid" 2>/dev/null || true; wait "$pid" 2>/dev/null || true; }
    [ -n "${monpid:-}" ] && { kill "$monpid" 2>/dev/null || true; wait "$monpid" 2>/dev/null || true; }
    rm -f "$fifo" 2>/dev/null || true
  }
  trap cleanup INT TERM EXIT

  rm -f "$fifo"
  mkfifo "$fifo"

  # Start swayidle once
  ( start_swayidle "$last" ) &
  pid=$!

  # Monitor power supply changes (writes events into FIFO)
  udevadm monitor --udev --subsystem-match=power_supply >"$fifo" &
  monpid=$!

  while IFS= read -r _line; do
    now="$(mode_now)"

    # Restart if mode changed OR swayidle died
    if [ "$now" != "$last" ] || ! kill -0 "$pid" 2>/dev/null; then
      if [ "$now" != "$last" ]; then
        echo "Power mode changed: $last -> $now" >&2
        last="$now"
      else
        echo "swayidle exited; restarting (mode=$last)" >&2
      fi

      kill "$pid" 2>/dev/null || true
      wait "$pid" 2>/dev/null || true
      ( start_swayidle "$last" ) &
      pid=$!
    fi
  done <"$fifo"
}

run