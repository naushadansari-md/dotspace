#!/usr/bin/env bash
set -euo pipefail

THEME="${HOME}/.config/rofi/applemenu.rasi"
ABOUT_SCRIPT="${HOME}/.config/waybar/scripts/about-system.sh"

entries() {
  printf '%s\0icon\x1fsystem-help\n' "About This System"
  printf '%s\0icon\x1fpreferences-system\n' "System Settings…"

  # Separator (works reliably)
  printf '%s\0nonselectable\x1ftrue\x1fclass\x1fseparator\n' "──────────────"

  printf '%s\0icon\x1fsystem-lock-screen\n' "Lock Screen"
  printf '%s\0icon\x1fsystem-suspend\n' "Sleep"

  printf '%s\0nonselectable\x1ftrue\x1fclass\x1fseparator\n' "──────────────"

  printf '%s\0icon\x1fsystem-reboot\n' "Restart…"
  printf '%s\0icon\x1fsystem-shutdown\n' "Shut Down…"
  printf '%s\0icon\x1fsystem-log-out\n' "Log Out…"
}

confirm() {
  printf "Cancel\nOK\n" | rofi -dmenu -i -p "$1" \
    -theme-str 'window{width:220px;} listview{lines:2;} inputbar{enabled:false;}' \
    | grep -qx "OK"
}

open_settings() {
  for cmd in \
    gnome-control-center \
    systemsettings \
    nwg-look \
    xfce4-settings-manager \
    mate-control-center \
    lxqt-config
  do
    if command -v "$cmd" >/dev/null 2>&1; then
      "$cmd" >/dev/null 2>&1 &
      return 0
    fi
  done
  notify-send "Apple Menu" "No settings app found."
  return 1
}

lock_screen() {
  if command -v hyprlock >/dev/null 2>&1; then
    hyprlock
  elif command -v swaylock >/dev/null 2>&1; then
    swaylock
  elif command -v gtklock >/dev/null 2>&1; then
    gtklock
  else
    loginctl lock-session || true
  fi
}

logout() {
  if command -v hyprctl >/dev/null 2>&1; then
    hyprctl dispatch exit
  elif command -v niri >/dev/null 2>&1; then
    niri msg quit
  else
    loginctl terminate-user "$USER"
  fi
}

choice="$(entries | rofi -dmenu -i -p "" -show-icons -theme "$THEME" || true)"

case "$choice" in
  "About This System")
    if [ -x "$ABOUT_SCRIPT" ]; then
      "$ABOUT_SCRIPT"
    else
      notify-send "Apple Menu" "Missing about script: $ABOUT_SCRIPT"
    fi
    ;;
  "System Settings…") open_settings ;;
  "Lock Screen") lock_screen ;;
  "Sleep") confirm "Sleep?" && systemctl suspend ;;
  "Restart…") confirm "Restart?" && systemctl reboot ;;
  "Shut Down…") confirm "Shut Down?" && systemctl poweroff ;;
  "Log Out…") confirm "Log Out?" && logout ;;
esac