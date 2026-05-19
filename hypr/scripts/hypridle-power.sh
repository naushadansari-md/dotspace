#!/bin/sh
# Optimized for MacBook Air 2017 (SMC/Intel HD 6000)
set -eu

# Prevent multiple instances
SCRIPT_NAME="hypridle-power.sh"
if pgrep -f "$SCRIPT_NAME" | grep -vq "$$"; then
  exit 0
fi

# Configuration Paths
WARN_SCRIPT="$HOME/.config/hypr/scripts/lock-warning.sh"
TEMPLATE="$HOME/.config/hypr/hypridle.conf"
ACTIVE_CONF="$HOME/.cache/hypridle.conf"

# Timings: AC vs Battery
AC_WARN=595; AC_LOCK=600; AC_OFF=900; AC_KBD=120
BAT_WARN=295; BAT_LOCK=300; BAT_OFF=420; BAT_KBD=30

# Precise path for MacBook Air 2017 Power Supply
get_ac_online() {
  if [ -f "/sys/class/power_supply/ADP1/online" ]; then
    cat "/sys/class/power_supply/ADP1/online"
  else
    # Fallback for generic power supply discovery
    for d in /sys/class/power_supply/*; do
      if [ -f "$d/online" ] && [ "$(cat "$d/type" 2>/dev/null)" = "Mains" ]; then
        cat "$d/online"
        return 0
      fi
    done
    echo 0
  fi
}

write_conf() {
  mode="$1"
  if [ "$mode" = "AC" ]; then
    WARN_T="$AC_WARN"; LOCK_T="$AC_LOCK"; OFF_T="$AC_OFF"; KBD_T="$AC_KBD"
  else
    WARN_T="$BAT_WARN"; LOCK_T="$BAT_LOCK"; OFF_T="$BAT_OFF"; KBD_T="$BAT_KBD"
  fi

  # KBD Block - Using smc::kbd_backlight for 2017 hardware
  # Added a small 50% restore on resume (Value: 127/255)
  KBD_BLOCK="
listener {
    timeout    = $KBD_T
    on-timeout = brightnessctl -d 'smc::kbd_backlight' set 0
    on-resume  = brightnessctl -d 'smc::kbd_backlight' set 51
}"

  mkdir -p "$(dirname "$ACTIVE_CONF")"
  WARN_ESC=$(printf '%s' "$WARN_SCRIPT" | sed 's/[\/&]/\\&/g')

  # Generate base config from template
  sed \
    -e "s/__WARN_T__/$WARN_T/g" \
    -e "s/__LOCK_T__/$LOCK_T/g" \
    -e "s/__OFF_T__/$OFF_T/g" \
    -e "s/__WARN_CMD__/$WARN_ESC/g" \
    "$TEMPLATE" > "$ACTIVE_CONF"

  # Append the hardware-specific keyboard listener
  printf "%s\n" "$KBD_BLOCK" >> "$ACTIVE_CONF"
}

# Cleanup function to kill hypridle properly on exit
cleanup() {
  pkill -P $$ hypridle 2>/dev/null || true
  exit 0
}

trap cleanup INT TERM EXIT

run_loop() {
  last_mode=""
  current_pid=""

  while :; do
    online="$(get_ac_online)"
    mode="BAT"; [ "$online" = "1" ] && mode="AC"

    if [ "$mode" != "$last_mode" ]; then
      # Gracefully kill previous hypridle instance
      if [ -n "$current_pid" ]; then
        kill "$current_pid" 2>/dev/null || true
        wait "$current_pid" 2>/dev/null || true
      fi

      write_conf "$mode"
      
      # Start hypridle with the new hardware-aware config
      hypridle -c "$ACTIVE_CONF" >/dev/null 2>&1 &
      current_pid=$!
      last_mode="$mode"
    fi
    
    # MacBook Air 2017 SMC is slow to update, 5s is safer for battery
    sleep 5
  done
}

run_loop