#!/usr/bin/env bash
set -euo pipefail

THEME="${HOME}/.config/rofi/aboutsystem.rasi"
ICON_TITLE="distributor-logo-archlinux"

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
    echo "Unknown GPU (install pciutils)"
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
    notify-send "About" "Install wl-clipboard (wl-copy) for copy"
  fi
}

open_settings() {
  for cmd in gnome-control-center systemsettings nwg-look xfce4-settings-manager mate-control-center lxqt-config; do
    if have "$cmd"; then
      "$cmd" >/dev/null 2>&1 &
      return 0
    fi
  done
  notify-send "About" "No settings app found"
  return 1
}

# ---- values ----
OS="Arch Linux"
KERNEL="$(uname -r)"
HOST="$(uname -n)"
CPU="$(cpu_model)"
MEM="$(mem_total_gib)"
GPU="$(gpu_name)"
UP="$(uptime_pretty)"

CPU_SHORT="$(printf "%s" "$CPU" | sed 's/(R)//g; s/(TM)//g; s/  */ /g' | cut -c1-48)"
GPU_SHORT="$(printf "%s" "$GPU" | sed 's/Intel Corporation //; s/  */ /g' | cut -c1-48)"

PLAIN="$(printf "OS: %s\nKernel: %s\nHost: %s\nCPU: %s\nMemory: %s\nGPU: %s\nUptime: %s\n" \
  "$OS" "$KERNEL" "$HOST" "$CPU" "$MEM" "$GPU" "$UP")"

menu() {
  printf '%s\0nonselectable\x1ftrue\x1fmarkup\x1ftrue\x1ficon\x1f%s\x1fclass\x1ftitle\n' \
    "<span weight='bold'>Arch Linux</span>" "$ICON_TITLE"

  printf '%s\0nonselectable\x1ftrue\x1fmarkup\x1ftrue\x1fclass\x1fsubtitle\n' \
    "<span alpha='70%'>About This System</span>"

  printf '%s\0nonselectable\x1ftrue\x1fclass\x1fdivider\n' "────────────────────"

  printf '%s\0nonselectable\x1ftrue\x1fmarkup\x1ftrue\x1fclass\x1finfo\n' "<span alpha='70%'>Kernel</span>   ${KERNEL}"
  printf '%s\0nonselectable\x1ftrue\x1fmarkup\x1ftrue\x1fclass\x1finfo\n' "<span alpha='70%'>Host</span>     ${HOST}"
  printf '%s\0nonselectable\x1ftrue\x1fmarkup\x1ftrue\x1fclass\x1finfo\n' "<span alpha='70%'>CPU</span>      ${CPU_SHORT}"
  printf '%s\0nonselectable\x1ftrue\x1fmarkup\x1ftrue\x1fclass\x1finfo\n' "<span alpha='70%'>Memory</span>   ${MEM}"
  printf '%s\0nonselectable\x1ftrue\x1fmarkup\x1ftrue\x1fclass\x1finfo\n' "<span alpha='70%'>GPU</span>      ${GPU_SHORT}"
  printf '%s\0nonselectable\x1ftrue\x1fmarkup\x1ftrue\x1fclass\x1finfo\n' "<span alpha='70%'>Uptime</span>   ${UP}"

  printf '%s\0nonselectable\x1ftrue\x1fclass\x1fdivider\n' "────────────────────"

  # Changed only these three icons
  printf '%s\0markup\x1ftrue\x1ficon\x1fedit-copy-symbolic\x1fclass\x1faction\n' "<span weight='bold'>Copy</span>"
  printf '%s\0markup\x1ftrue\x1ficon\x1fpreferences-system-symbolic\x1fclass\x1faction\n' "<span weight='bold'>Settings</span>"
  printf '%s\0markup\x1ftrue\x1ficon\x1fwindow-close-symbolic\x1fclass\x1faction\n' "<span weight='bold'>Close</span>"
}

choice="$(menu | rofi -dmenu -i -p "" -show-icons -markup-rows -no-custom \
  -icon-theme "AppMenu" \
  -theme "$THEME" || true)"

case "$choice" in
  *Copy*)     copy_to_clipboard "$PLAIN" ;;
  *Settings*) open_settings ;;
  *Close*|"") exit 0 ;;
esac