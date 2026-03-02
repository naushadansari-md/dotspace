#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

# These are the symlinked folders you showed in ~/.config (arrow icon)
LINK_DIRS=(
  "autostart"
  "fuzzel"
  "google-chrome"
  "gtk-3.0"
  "gtk-4.0"
  "hypr"
  "JetBrains"
  "kitty"
  "misc"
  "niri"
  "nwg-dock-hyprland"
  "nwg-drawer"
  "nwg-look"
  "swaync"
  "systemd"
  "waybar"
  "xsettingsd"
  "yazi"
  "zathura"
  "zsh"
)

# These files are also in ~/.config (optional to link if you keep them in repo)
LINK_FILES=(
  "mimeapps.list"
  "pavucontrol.ini"
  "user-dirs.dirs"
  "user-dirs.locale"
)

info()  { printf "\033[1;34m[i]\033[0m %s\n" "$*"; }
warn()  { printf "\033[1;33m[!]\033[0m %s\n" "$*"; }

backup_if_needed() {
  local target="$1"
  if [[ -e "$target" || -L "$target" ]]; then
    mkdir -p "$BACKUP_DIR"
    info "Backing up: $target -> $BACKUP_DIR/"
    mv "$target" "$BACKUP_DIR/"
  fi
}

link_any() {
  local src="$1"
  local dest="$2"

  if [[ ! -e "$src" ]]; then
    warn "Skip (not found in repo): $src"
    return 0
  fi

  if [[ -L "$dest" ]]; then
    local cur
    cur="$(readlink "$dest" || true)"
    if [[ "$cur" == "$src" ]]; then
      info "Already linked: $dest -> $src"
      return 0
    fi
  fi

  backup_if_needed "$dest"
  info "Linking: $dest -> $src"
  ln -sfn "$src" "$dest"
}

mkdir -p "$CONFIG_DIR"

info "Repo:   $REPO_DIR"
info "Config: $CONFIG_DIR"

for d in "${LINK_DIRS[@]}"; do
  link_any "$REPO_DIR/$d" "$CONFIG_DIR/$d"
done

for f in "${LINK_FILES[@]}"; do
  link_any "$REPO_DIR/$f" "$CONFIG_DIR/$f"
done

if [[ -d "$BACKUP_DIR" ]]; then
  info "Backup saved at: $BACKUP_DIR"
else
  info "No backups needed."
fi

info "Done ✅"
