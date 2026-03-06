#!/usr/bin/env bash
set -euo pipefail

# dotspace installer
# - Arch / Arch-based detection
# - Safe backups
# - Dry-run support
# - Symlink configs into ~/.config
# - Symlink repo .zshrc into ~/.zshrc

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

DRY_RUN=0
FORCE=0

# ---------- Pretty output ----------
info() { printf "\033[1;34m[i]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[!]\033[0m %s\n" "$*"; }
err()  { printf "\033[1;31m[x]\033[0m %s\n" "$*"; }

run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf "\033[1;36m[dry]\033[0m %s\n" "$*"
  else
    eval "$@"
  fi
}

# ---------- Arguments ----------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --force)   FORCE=1; shift ;;
    -h|--help)
      echo "Usage: ./install.sh [--dry-run] [--force]"
      exit 0
      ;;
    *) err "Unknown option: $1"; exit 1 ;;
  esac
done

# ---------- OS Detection ----------
if [[ ! -r /etc/os-release ]]; then
  err "Cannot detect OS (missing /etc/os-release)."
  exit 1
fi

# shellcheck disable=SC1091
. /etc/os-release

if [[ "${ID:-}" == "arch" ]] || [[ "${ID_LIKE:-}" == *"arch"* ]]; then
  info "OS detected: ${PRETTY_NAME:-Arch Linux} ✔"
else
  warn "Detected OS: ${PRETTY_NAME:-unknown}"
  warn "This setup is intended for Arch-based systems."
  if [[ "$FORCE" -ne 1 ]]; then
    read -rp "Continue anyway? [y/N]: " ans
    case "$ans" in
      y|Y|yes|YES) ;;
      *) info "Aborted."; exit 1 ;;
    esac
  fi
fi

# ---------- Config folders (match your repo) ----------
LINK_DIRS=(
  "gtk-3.0"
  "gtk-4.0"
  "hypr"
  "kitty"
  "matugen"
  "misc"
  "niri"
  "nwg-dock-hyprland"
  "nwg-drawer"
  "nwg-look"
  "rofi"
  "swaylock"
  "swaync"
  "systemd"
  "walker"
  "waybar"
  "xsettingsd"
  "yazi"
  "zathura"
  "zsh"
  
)

# ---------- Home dotfiles to link (repo root -> $HOME) ----------
HOME_FILES=(
  ".zshrc"
)

backup_if_needed() {
  local target="$1"
  if [[ -e "$target" || -L "$target" ]]; then
    run "mkdir -p \"$BACKUP_DIR\""
    info "Backing up: $target"
    run "mv \"$target\" \"$BACKUP_DIR/\""
  fi
}

already_linked() {
  local dest="$1"
  local src="$2"
  [[ -L "$dest" ]] && [[ "$(readlink "$dest")" == "$src" ]]
}

link_dir() {
  local src="$1"
  local dest="$2"

  if [[ ! -d "$src" ]]; then
    warn "Skip (missing in repo): $src"
    return 0
  fi

  if already_linked "$dest" "$src"; then
    info "Already linked: $dest"
    return 0
  fi

  backup_if_needed "$dest"
  info "Linking: $dest -> $src"
  run "ln -sfn \"$src\" \"$dest\""
}

link_file() {
  local src="$1"
  local dest="$2"

  if [[ ! -f "$src" ]]; then
    warn "Skip (missing file in repo): $src"
    return 0
  fi

  if already_linked "$dest" "$src"; then
    info "Already linked: $dest"
    return 0
  fi

  backup_if_needed "$dest"
  info "Linking: $dest -> $src"
  run "ln -sfn \"$src\" \"$dest\""
}

# ---------- Execution ----------
info "Repo:   $REPO_DIR"
info "Config: $CONFIG_DIR"
[[ "$DRY_RUN" -eq 1 ]] && warn "Dry-run mode enabled"

run "mkdir -p \"$CONFIG_DIR\""

# Link ~/.config folders
for d in "${LINK_DIRS[@]}"; do
  link_dir "$REPO_DIR/$d" "$CONFIG_DIR/$d"
done

# Link home dotfiles (like ~/.zshrc)
for f in "${HOME_FILES[@]}"; do
  link_file "$REPO_DIR/$f" "$HOME/$f"
done

if [[ "$DRY_RUN" -eq 0 && -d "$BACKUP_DIR" ]]; then
  info "Backup saved at: $BACKUP_DIR"
fi

info "Done ✅"