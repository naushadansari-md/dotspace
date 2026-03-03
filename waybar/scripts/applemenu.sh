#!/usr/bin/env bash
set -euo pipefail

THEME="${HOME}/.config/rofi/applemenu.rasi"
ABOUT_SCRIPT="${HOME}/.config/waybar/scripts/about-system.sh"

entries() {
  printf '%s\0icon\x1fhelp-about-symbolic\n' "About This System"
  printf '%s\0icon\x1fpreferences-system-symbolic\n' "System Settings"

  printf '%s\0nonselectable\x1ftrue\x1fclass\x1fseparator\n' "──────────────"

  printf '%s\0icon\x1fsystem-lock-screen-symbolic\n' "Lock Screen"
  printf '%s\0icon\x1fsystem-suspend-symbolic\n' "Sleep"

  printf '%s\0nonselectable\x1ftrue\x1fclass\x1fseparator\n' "──────────────"

  printf '%s\0icon\x1fsystem-reboot-symbolic\n' "Restart"
  printf '%s\0icon\x1fsystem-shutdown-symbolic\n' "Shut Down"
  printf '%s\0icon\x1fsystem-log-out-symbolic\n' "Log Out"
}

confirm() {
  local prompt="$1"
  printf "Cancel\nOK\n" | rofi -dmenu -i -p "$prompt" \
    -no-custom -selected-row 1 \
    -theme "${HOME}/.config/rofi/confirm.rasi" \
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

choice="$(entries | rofi -dmenu -i -p "" \
  -show-icons \
  -icon-theme "AppleMenu" \
  -theme "$THEME" || true)"

[ -n "${choice:-}" ] || exit 0

case "$choice" in
  "About This System")
    [ -x "$ABOUT_SCRIPT" ] && "$ABOUT_SCRIPT" \
      || notify-send "Apple Menu" "Missing about script: $ABOUT_SCRIPT"
    ;;
  "System Settings") open_settings ;;
  "Lock Screen")      lock_screen ;;
  "Sleep")            confirm "Sleep?" && systemctl suspend ;;
  "Restart")         confirm "Restart?" && systemctl reboot ;;
  "Shut Down")       confirm "Shut Down?" && systemctl poweroff ;;
  "Log Out")         confirm "Log Out?" && hyprctl dispatch exit ;;
esac