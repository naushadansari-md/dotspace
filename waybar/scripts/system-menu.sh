#!/usr/bin/env bash
set -euo pipefail

THEME="$HOME/.config/rofi/system-menu.rasi"
CONFIRM_THEME="$HOME/.config/rofi/confirm.rasi"
ABOUT_SCRIPT="$HOME/.config/waybar/scripts/about-system.sh"

MAX_RECENT=15

menu() {
  rofi -dmenu -i -markup-rows -p "" -theme "$THEME"
}

confirm_action() {
  printf "Cancel\nOK\n" \
    | rofi -dmenu -i -p "Confirm" \
        -theme "$CONFIRM_THEME" \
        -no-custom \
        -selected-row 1 \
    | grep -qx "OK"
}

entries() {
  printf '%s\n' "󰌢  About This System"
  printf '%s\n' "---"
  printf '%s\n' "󰒓  System Settings"
  printf '%s\n' "󰀻  Applications ›"
  printf '%s\n' "---"
  printf '%s\n' "󰉋  Recent Items ›"
  printf '%s\n' "---"
  printf '%s\n' "󰒲  Sleep"
  printf '%s\n' "󰑓  Restart"
  printf '%s\n' "󰐥  Shut Down"
  printf '%s\n' "---"
  printf '%s\n' "󰌾  Lock Screen"
  printf '%s\n' "󰍃  Log Out"
}

open_settings() {
  local cmd
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

  notify-send "No settings application found"
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

logout_user() {
  if command -v hyprctl >/dev/null 2>&1; then
    hyprctl dispatch exit
  elif command -v niri >/dev/null 2>&1; then
    niri msg quit
  else
    loginctl terminate-user "$USER"
  fi
}

show_applications() {
  rofi -show drun -theme "$HOME/.config/rofi/applications.rasi" -p "Search Apps"
}

get_recent_paths() {
  local recent="$HOME/.local/share/recently-used.xbel"
  [[ -f "$recent" ]] || return 0

  grep -oP 'href="\K[^"]+' "$recent" \
    | sed 's#^file://##' \
    | python3 -c 'import sys, urllib.parse
for line in sys.stdin:
    print(urllib.parse.unquote(line.strip()))' \
    | awk '!seen[$0]++'
}

show_recent_files() {
  local -a rows=()
  local path choice row display real_path
  local count=0

  while IFS= read -r path; do
    [[ -f "$path" ]] || continue
    rows+=("$(basename "$path") — $(basename "$(dirname "$path")")|$path")
    count=$((count + 1))
    [[ $count -ge $MAX_RECENT ]] && break
  done < <(get_recent_paths)

  if [[ ${#rows[@]} -eq 0 ]]; then
    notify-send "No recent files"
    return 1
  fi

  choice="$(
    printf '%s\n' "${rows[@]}" \
      | cut -d'|' -f1 \
      | rofi -dmenu -i -p "Recent Files" -theme "$THEME"
  )" || return 0

  [[ -n "${choice:-}" ]] || return 0

  for row in "${rows[@]}"; do
    display="${row%%|*}"
    real_path="${row#*|}"
    if [[ "$choice" == "$display" ]]; then
      xdg-open "$real_path" >/dev/null 2>&1 &
      return 0
    fi
  done
}

show_recent_folders() {
  local -A seen=()
  local -a rows=()
  local path folder choice row display real_folder

  while IFS= read -r path; do
    [[ -f "$path" ]] || continue
    folder="$(dirname "$path")"
    [[ -d "$folder" ]] || continue
    [[ -n "${seen[$folder]+x}" ]] && continue
    seen["$folder"]=1

    rows+=("$(basename "$folder")/ — $(basename "$(dirname "$folder")")|$folder")
  done < <(get_recent_paths)

  if [[ ${#rows[@]} -eq 0 ]]; then
    notify-send "No recent folders"
    return 1
  fi

  choice="$(
    printf '%s\n' "${rows[@]}" \
      | cut -d'|' -f1 \
      | rofi -dmenu -i -p "Recent Folders" -theme "$THEME"
  )" || return 0

  [[ -n "${choice:-}" ]] || return 0

  for row in "${rows[@]}"; do
    display="${row%%|*}"
    real_folder="${row#*|}"
    if [[ "$choice" == "$display" ]]; then
      xdg-open "$real_folder" >/dev/null 2>&1 &
      return 0
    fi
  done
}

clear_recent_items() {
  rm -f "$HOME/.local/share/recently-used.xbel"
  notify-send "Recent items cleared"
}

show_recent_menu() {
  local choice

  choice="$(
    {
      printf '%s\n' "󰈙  Recent Files ▶"
      printf '%s\n' "󰉋  Recent Folders ▶"
      printf '%s\n' "󰆴  Clear Recent Items"
    } | rofi -dmenu -i -p "Recent Items" -theme "$THEME"
  )" || return 0

  case "$choice" in
    "󰈙  Recent Files ▶")
      show_recent_files
      ;;
    "󰉋  Recent Folders ▶")
      show_recent_folders
      ;;
    "󰆴  Clear Recent Items")
      confirm_action && clear_recent_items
      ;;
  esac
}

main() {
  local choice

  choice="$(
    entries | menu
  )" || exit 0

  [[ -n "${choice:-}" ]] || exit 0

  case "$choice" in
    "󰌢  About This System")
      [[ -x "$ABOUT_SCRIPT" ]] && "$ABOUT_SCRIPT"
      ;;
    "󰒓  System Settings")
      open_settings
      ;;
    "󰀻  Applications ▶")
      show_applications
      ;;
    "󰉋  Recent Items ▶")
      show_recent_menu
      ;;
    "󰒲  Sleep")
      confirm_action && systemctl suspend
      ;;
    "󰑓  Restart")
      confirm_action && systemctl reboot
      ;;
    "󰐥  Shut Down")
      confirm_action && systemctl poweroff
      ;;
    "󰌾  Lock Screen")
      lock_screen
      ;;
    "󰍃  Log Out")
      confirm_action && logout_user
      ;;
  esac
}

main "$@"