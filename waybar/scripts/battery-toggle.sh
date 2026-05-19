#!/usr/bin/env bash
set -euo pipefail

MODE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/waybar/battery_mode"
MODE="pct"
[[ -f "$MODE_FILE" ]] && MODE="$(cat "$MODE_FILE" 2>/dev/null || echo pct)"

BAT_PATH="$(upower -e | grep -m1 'BAT' || true)"
if [[ -z "${BAT_PATH}" ]]; then
  printf '{"text":" N/A","tooltip":"Battery not found","class":"battery"}\n'
  exit 0
fi

INFO="$(upower -i "$BAT_PATH")"

# ✅ FIXED: Rounded percentage (no decimals)
PCT="$(printf "%s\n" "$INFO" | awk -F': *' '/percentage:/ {gsub("%","",$2); printf "%.0f", $2; exit}')"

STATE="$(printf "%s\n" "$INFO" | awk -F': *' '/state:/ {print $2; exit}')"
TEMPTY="$(printf "%s\n" "$INFO" | awk -F': *' '/time to empty:/ {print $2; exit}')"
TFULL="$(printf "%s\n" "$INFO" | awk -F': *' '/time to full:/ {print $2; exit}')"

# Safe defaults
PCT="${PCT:-0}"
STATE="${STATE:-unknown}"

# Icons
if [[ "$STATE" == "charging" ]]; then
  if   [[ "$PCT" -ge 90 ]]; then icon="󰂅"
  elif [[ "$PCT" -ge 70 ]]; then icon="󰂋"
  elif [[ "$PCT" -ge 50 ]]; then icon="󰂉"
  elif [[ "$PCT" -ge 25 ]]; then icon="󰂈"
  else icon="󰂇"
  fi
else
  if   [[ "$PCT" -ge 90 ]]; then icon=""
  elif [[ "$PCT" -ge 70 ]]; then icon=""
  elif [[ "$PCT" -ge 50 ]]; then icon=""
  elif [[ "$PCT" -ge 25 ]]; then icon=""
  else icon=""
  fi
fi

# Time string
time_str=""
if [[ "$STATE" == "discharging" ]]; then
  time_str="${TEMPTY:-}"
elif [[ "$STATE" == "charging" ]]; then
  time_str="${TFULL:-}"
fi

# Text display
if [[ "$MODE" == "time" && -n "$time_str" && "$time_str" != "unknown" ]]; then
  TEXT="${time_str} ${icon}"
else
  TEXT="${icon} ${PCT}%"
fi

# Tooltip
TIP="Battery: ${PCT}%\nState: ${STATE}"
if [[ -n "$time_str" && "$time_str" != "unknown" ]]; then
  if [[ "$STATE" == "discharging" ]]; then
    TIP="${TIP}\nTime to empty: ${time_str}"
  elif [[ "$STATE" == "charging" ]]; then
    TIP="${TIP}\nTime to full: ${time_str}"
  fi
fi

# Class for CSS
CLASS="battery"
if [[ "$STATE" == "charging" ]]; then
  CLASS="$CLASS charging"
fi
if [[ "$PCT" -le 15 ]]; then
  CLASS="$CLASS critical"
elif [[ "$PCT" -le 30 ]]; then
  CLASS="$CLASS warning"
fi

# JSON escape
json_escape() {
  sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e ':a;N;$!ba;s/\n/\\n/g'
}

printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' \
  "$(printf "%s" "$TEXT"  | json_escape)" \
  "$(printf "%s" "$TIP"   | json_escape)" \
  "$(printf "%s" "$CLASS" | json_escape)"
