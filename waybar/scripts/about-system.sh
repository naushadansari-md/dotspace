#!/usr/bin/env bash
set -euo pipefail

THEME="${HOME}/.config/rofi/about-system.rasi"

have() { command -v "$1" >/dev/null 2>&1; }

cpu_model() {
  awk -F: '/model name/ {gsub(/^[ \t]+/,"",$2); print $2; exit}' /proc/cpuinfo 2>/dev/null || echo "Unknown CPU"
}

mem_total_gib() {
  awk '/MemTotal/ {printf "%.1f GiB", $2/1024/1024}' /proc/meminfo 2>/dev/null || echo "Unknown"
}

gpu_name() {
  if have lspci; then
    lspci | awk -F': ' '/VGA compatible controller|3D controller/ {print $2; exit}'
  else
    echo "Unknown GPU"
  fi
}

uptime_pretty() {
  if have uptime; then
    uptime -p 2>/dev/null | sed 's/^up //'
  else
    awk '{printf "%.0f minutes", $1/60}' /proc/uptime 2>/dev/null
  fi
}

copy_to_clipboard() {
  local text="$1"

  if have wl-copy; then
    printf "%s" "$text" | wl-copy
    notify-send "About" "Copied to clipboard"
  elif have xclip; then
    printf "%s" "$text" | xclip -selection clipboard
    notify-send "About" "Copied to clipboard"
  else
    notify-send "About" "Install wl-clipboard or xclip"
  fi
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
    if have "$cmd"; then
      "$cmd" >/dev/null 2>&1 &
      return 0
    fi
  done

  notify-send "About" "No settings app found"
  return 1
}

OS="Arch Linux"
KERNEL="$(uname -r)"
HOST="$(uname -n)"
CPU="$(cpu_model)"
MEM="$(mem_total_gib)"
GPU="$(gpu_name)"
UP="$(uptime_pretty)"

CPU_SHORT="$(printf "%s" "$CPU" | sed 's/(R)//g; s/(TM)//g; s/  */ /g' | cut -c1-40)"
GPU_SHORT="$(printf "%s" "$GPU" | sed 's/Intel Corporation //; s/ (rev .*//g; s/  */ /g; s/Alder Lake-UP3 GT1 \[UHD Graphics\]/UHD Graphics/g' | cut -c1-40)"

PLAIN="$(printf "OS: %s\nKernel: %s\nHost: %s\nCPU: %s\nMemory: %s\nGPU: %s\nUptime: %s\n" \
  "$OS" "$KERNEL" "$HOST" "$CPU" "$MEM" "$GPU" "$UP")"

menu() {
  printf '<span weight="bold" size="large">󰣇  %s</span>\n' "$OS"
  printf '<span alpha="70%%">About This System</span>\n'

  printf '%s\n' "──────────────"

  printf '󰌢  <span alpha="70%%">Model</span>    %s\n' "$HOST"
  printf '󰒋  <span alpha="70%%">Kernel</span>   %s\n' "$KERNEL"
  printf '󰍛  <span alpha="70%%">CPU</span>      %s\n' "$CPU_SHORT"
  printf '󰘚  <span alpha="70%%">Memory</span>   %s\n' "$MEM"
  printf '󰢮  <span alpha="70%%">GPU</span>      %s\n' "$GPU_SHORT"
  printf '󰥔  <span alpha="70%%">Uptime</span>   %s\n' "$UP"

  printf '%s\n' "──────────────"

  printf '󰆏  Copy\n'
  printf '󰒓  Settings\n'
  printf '󰅖  Close\n'
}

choice="$(
  menu | rofi -dmenu -i -markup-rows -p "" \
    -no-custom \
    -theme "$THEME" || true
)"

case "$choice" in
  *Copy*)     copy_to_clipboard "$PLAIN" ;;
  *Settings*) open_settings ;;
  *Close*|"") exit 0 ;;
esac