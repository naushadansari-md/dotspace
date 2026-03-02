#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info() { printf "\033[1;34m[i]\033[0m %s\n" "$*"; }
err()  { printf "\033[1;31m[x]\033[0m %s\n" "$*"; }

usage() {
  cat <<'EOF'
Usage: ./setup.sh [options]

Runs:
  1) ./install-packages.sh
  2) ./install.sh

Options (forwarded to both scripts when applicable):
  --dry-run
  --force
  --aur-helper yay|paru
  -h, --help
EOF
}

# Collect args to pass through
ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run|--force) ARGS+=("$1"); shift ;;
    --aur-helper)
      ARGS+=("$1" "${2:-}")
      shift 2
      ;;
    -h|--help) usage; exit 0 ;;
    *) err "Unknown option: $1"; usage; exit 1 ;;
  esac
done

PACKAGES="$REPO_DIR/install-packages.sh"
DOTS="$REPO_DIR/install.sh"

[[ -x "$PACKAGES" ]] || { err "Missing or not executable: $PACKAGES"; exit 1; }
[[ -x "$DOTS" ]]     || { err "Missing or not executable: $DOTS"; exit 1; }

info "Repo: $REPO_DIR"
info "Step 1/2: Installing packages..."
"$PACKAGES" "${ARGS[@]}"

info "Step 2/2: Linking dotfiles/configs..."
"$DOTS" "${ARGS[@]}"

info "All done ✅"
