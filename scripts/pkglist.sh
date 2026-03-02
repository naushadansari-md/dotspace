#!/usr/bin/env bash
set -euo pipefail

command -v pacman >/dev/null 2>&1 || { echo "pacman not found"; exit 1; }

OUT_DIR="${1:-packages}"

# If user passes relative path, make it relative to repo root
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_PATH="$REPO_DIR/$OUT_DIR"

mkdir -p "$OUT_PATH"

pacman -Qqen | sort -u > "$OUT_PATH/pkglist.txt"
pacman -Qqem | sort -u > "$OUT_PATH/aur-pkglist.txt"
cat "$OUT_PATH/pkglist.txt" "$OUT_PATH/aur-pkglist.txt" | sort -u > "$OUT_PATH/pkglist-all.txt"

echo "Saved:"
echo "  $OUT_PATH/pkglist.txt"
echo "  $OUT_PATH/aur-pkglist.txt"
echo "  $OUT_PATH/pkglist-all.txt"
