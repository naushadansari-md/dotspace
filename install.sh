#!/usr/bin/env bash
set -euo pipefail

# dotspace installer:
# - Detect OS (Arch/Arch-based)
# - Backup existing ~/.config/<item> before linking
# - Symlink repo folders into ~/.config
#
# Usage:
#   ./install.sh
#   ./install.sh --dry-run
#   ./install.sh --force
#
# Notes:
# - Run from anywhere; it resolves repo directory automatically.
# - If you move/rename the repo folder, absolute symlinks can break.
#   Keep it in a stable location (e.g., ~/dotspace or ~/dotfiles/dotspace).

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

DRY_RUN=0
FORCE=0

# -------- Pretty output helpers --------
info() { printf "\033[1;34m[i]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[!]\033[0m %s\n" "$*"; }
err()  { printf "\033[1;31m[x]\033[0m %s\n" "$*"; }

run() {
  # wrapper that supports dry-run
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf "\033[1;36m[dry]\033[0m %s\n" "$*"
  else
    eval "$@"
  fi
}

# -------- Args --------
usage() {
  cat <<'EOF'
dotspace install.sh

Options:
  --dry-run    Show actions without changing anything
  --force      Don't prompt on non-Arch OS (still warns)
  -h, --help   Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --force)   FORCE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) err "Unknown option: $1"; usage; exit 1 ;;
  esac
done

# -------- OS detection (Arch-only warning) --------
detect_os() {
  if [[ ! -r /etc/os-release ]]; then
    err "Cannot detect OS (missing /etc/os-release)"
    exit 1
  fi

  # shellcheck disable=SC1091
  . /etc/os-release

  local id="${ID:-unknown}"
  local like="${ID_LIKE:-}"
  local pretty="${PRETTY_NAME:-unknown}"

  # Accept Arch or Arch-based
  if [[ "$id" == "arch" ]] || [[ "$like" == *"arch"* ]]; then
    info "OS detected: $pretty (supported)"
    return 0
  fi

  warn "OS detected: $pretty (unsupported for this dotfiles setup)"
  warn "This repo is intended for Arch/Arch-based systems."
  if [[ "$FORCE" -eq 1 ]]; then
    warn "--force used: continuing anyway."
    return 0
  fi

  read -rp "Continue anyway? [y/N]: " ans
  case "$ans" in
    y|Y|yes|YES) ;;
    *) info "Aborted."; exit 1 ;;
  esac
}

# -------- Link targets (based on your repo folders) --------
# These are repo directories to link into ~/.config/<name>
LINK_DIRS=(
  "fuzzel"
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
  "swaylock"
  "swaync"
  "systemd"
  "waybar"
  "xsettingsd"
  "yazi"
  "zathura"
  "zsh"
)

# Optional files at repo root to link into ~/.config/<file>
# (only linked if they exist in the repo)
LINK_FILES=(
  "mimeapps.list"
  "pavucontrol.ini"
  "user-dirs.dirs"
  "user-dirs.locale"
)

backup_if_needed() {
  local target="$1"

  if [[ -e "$target" || -L "$target" ]]; then
    run "mkdir -p \"$BACKUP_DIR\""
    info "Backing up: $target -> $BACKUP_DIR/"
    run "mv \"$target\" \"$BACKUP_DIR/\""
  fi
}

already_correct_link() {
  local dest="$1"
  local src="$2"

  if [[ -L "$dest" ]]; then
    local cur
    cur="$(readlink "$dest" || true)"
    [[ "$cur" == "$src" ]] && return 0
  fi
  return 1
}

link_any() {
  local src="$1"
  local dest="$2"

  if [[ ! -e "$src" ]]; then
    warn "Skip (not found in repo): $src"
    return 0
  fi

  if already_correct_link "$dest" "$src"; then
    info "Already linked: $dest -> $src"
    return 0
  fi

  backup_if_needed "$dest"
  info "Linking: $dest -> $src"
  run "ln -sfn \"$src\" \"$dest\""
}

main() {
  detect_os

  info "Repo:   $REPO_DIR"
  info "Config: $CONFIG_DIR"
  [[ "$DRY_RUN" -eq 1 ]] && warn "Dry-run mode enabled: no changes will be made."

  run "mkdir -p \"$CONFIG_DIR\""

  # Link directories
  for d in "${LINK_DIRS[@]}"; do
    link_any "$REPO_DIR/$d" "$CONFIG_DIR/$d"
  done

  # Link files (optional)
  for f in "${LINK_FILES[@]}"; do
    link_any "$REPO_DIR/$f" "$CONFIG_DIR/$f"
  done

  if [[ "$DRY_RUN" -eq 0 && -d "$BACKUP_DIR" ]]; then
    info "Backup saved at: $BACKUP_DIR"
  elif [[ "$DRY_RUN" -eq 0 ]]; then
    info "No backups needed."
  fi

  info "Done ✅"
}

main