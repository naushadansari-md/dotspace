#!/bin/sh
set -eu

WARN="$HOME/.config/niri/lock-warning.sh"
SELF="$HOME/.config/niri/scripts/swayidle-power.sh"

# -------- Timeouts --------

# On AC
AC_WARN=595
AC_LOCK=600
AC_OFF=900

# On battery
BAT_WARN=295
BAT_LOCK=300
BAT_OFF=420

# --------------------------

pid=""
last=""

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

stop_pid_wait() {
  p="${1:-}"
  [ -n "$p" ] || return 0
  kill -TERM "$p" 2>/dev/null || true
  wait "$p" 2>/dev/null || true
}

stop_pid_nowait() {
  p="${1:-}"
  [ -n "$p" ] || return 0
  kill -TERM "$p" 2>/dev/null || true
}

cleanup() {
  trap - INT TERM
  stop_pid_nowait "$pid"
  exit 0
}

start_swayidle() {
  mode="$1"

  if [ "$mode" = "AC" ]; then
    WARN_T="$AC_WARN"
    LOCK_T="$AC_LOCK"
    OFF_T="$AC_OFF"
  else
    WARN_T="$BAT_WARN"
    LOCK_T="$BAT_LOCK"
    OFF_T="$BAT_OFF"
  fi

  swayidle -w \
    timeout "$WARN_T" "$WARN" \
    timeout "$LOCK_T" 'swaylock -f' \
    timeout "$OFF_T" "$SELF --outputs-off" \
    resume "$SELF --outputs-on" \
    before-sleep 'swaylock -f' &

  echo $!
}

run_loop() {
  trap cleanup INT TERM

  while :; do
    online="$(get_ac_online)"
    mode="BAT"
    [ "$online" = "1" ] && mode="AC"

    if [ "$mode" != "$last" ]; then
      stop_pid_wait "$pid"
      pid="$(start_swayidle "$mode")"
      last="$mode"
    fi

    sleep 2
  done
}

case "${1:-}" in
  --outputs-off) outputs_off; exit 0 ;;
  --outputs-on) outputs_on; exit 0 ;;
esac

run_loop