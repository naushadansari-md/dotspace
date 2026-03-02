#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKG_DIR="$REPO_DIR/packages"
PACMAN_LIST="$PKG_DIR/pkglist.txt"
AUR_LIST="$PKG_DIR/aur-pkglist.txt"

DRY_RUN=0
FORCE=0
AUR_HELPER=""   # auto-detect if empty

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

usage() {
  cat <<'EOF'
Usage: ./install-packages.sh [options]

Options:
  --dry-run            Show commands without executing
  --force              Don't prompt (use carefully)
  --aur-helper <tool>  Choose AUR helper: yay | paru
  -h, --help           Show help

Notes:
- Official repo packages are read from: packages/pkglist.txt
- AUR packages are read from: packages/aur-pkglist.txt (only if non-empty)
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --force)   FORCE=1; shift ;;
    --aur-helper)
      AUR_HELPER="${2:-}"
      [[ -n "$AUR_HELPER" ]] || { err "--aur-helper needs a value (yay|paru)"; exit 1; }
      shift 2
      ;;
    -h|--help) usage; exit 0 ;;
    *) err "Unknown option: $1"; usage; exit 1 ;;
  esac
done

# --- OS detection (Arch/Arch-based) ---
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
  warn "This script is intended for Arch-based systems."
  if [[ "$FORCE" -ne 1 ]]; then
    read -rp "Continue anyway? [y/N]: " ans
    case "$ans" in y|Y|yes|YES) ;; *) info "Aborted."; exit 1 ;; esac
  fi
fi

command -v pacman >/dev/null 2>&1 || { err "pacman not found."; exit 1; }

[[ -f "$PACMAN_LIST" ]] || { err "Missing: $PACMAN_LIST"; exit 1; }
[[ -f "$AUR_LIST" ]] || { warn "Missing: $AUR_LIST (AUR step will be skipped)"; }

# Count AUR lines safely (ignore blanks/comments)
# IMPORTANT FIX:
# With `set -euo pipefail`, grep returning 1 (no matches) would exit the script.
aur_count=0
if [[ -f "$AUR_LIST" ]]; then
  aur_count="$(
    { grep -vE '^\s*($|#)' "$AUR_LIST" || true; } | wc -l | tr -d ' '
  )"
fi

info "Repo:        $REPO_DIR"
info "Packages:    $PACMAN_LIST"
info "AUR list:    $AUR_LIST (entries: $aur_count)"
[[ "$DRY_RUN" -eq 1 ]] && warn "Dry-run mode enabled"

if [[ "$FORCE" -ne 1 ]]; then
  read -rp "Proceed to install packages? [y/N]: " ans
  case "$ans" in y|Y|yes|YES) ;; *) info "Aborted."; exit 1 ;; esac
fi

# --- Install official packages ---
info "Updating system + installing official packages..."
run "sudo pacman -Syu --needed - < \"$PACMAN_LIST\""

# --- AUR helper detection ---
detect_aur_helper() {
  if [[ -n "$AUR_HELPER" ]]; then
    command -v "$AUR_HELPER" >/dev/null 2>&1 || { err "AUR helper '$AUR_HELPER' not found in PATH"; exit 1; }
    return 0
  fi

  if command -v yay >/dev/null 2>&1; then
    AUR_HELPER="yay"
  elif command -v paru >/dev/null 2>&1; then
    AUR_HELPER="paru"
  else
    AUR_HELPER=""
  fi
}

install_yay() {
  info "Installing yay (AUR helper)..."
  run "sudo pacman -S --needed --noconfirm git base-devel"
  run "rm -rf /tmp/yay"
  run "git clone https://aur.archlinux.org/yay.git /tmp/yay"
  run "cd /tmp/yay && makepkg -si --noconfirm"
}

# --- Install AUR packages (if any) ---
if [[ "$aur_count" -eq 0 ]]; then
  info "No AUR packages to install (aur-pkglist.txt is empty). Skipping AUR step."
  info "Done ✅"
  exit 0
fi

detect_aur_helper

if [[ -z "$AUR_HELPER" ]]; then
  warn "AUR packages exist but no AUR helper found (yay/paru)."
  if [[ "$FORCE" -eq 1 ]]; then
    warn "--force used: attempting to install yay automatically."
    install_yay
    AUR_HELPER="yay"
  else
    read -rp "Install 'yay' now to continue with AUR packages? [y/N]: " ans
    case "$ans" in
      y|Y|yes|YES) install_yay; AUR_HELPER="yay" ;;
      *) warn "Skipping AUR packages."; info "Done ✅"; exit 0 ;;
    esac
  fi
fi

info "Installing AUR packages using: $AUR_HELPER"
# shellcheck disable=SC2016
run "$AUR_HELPER -S --needed - < \"$AUR_LIST\""

info "Done ✅"