#!/usr/bin/env bash
set -euo pipefail

command -v pacman >/dev/null 2>&1 || { echo "pacman not found"; exit 1; }

OUT_DIR="${1:-packages}"
mkdir -p "$OUT_DIR"

pacman -Qqen | sort -u > "$OUT_DIR/pkglist.txt"
pacman -Qqem | sort -u > "$OUT_DIR/aur-pkglist.txt"
cat "$OUT_DIR/pkglist.txt" "$OUT_DIR/aur-pkglist.txt" | sort -u > "$OUT_DIR/pkglist-all.txt"

echo "Saved:"
echo "  $OUT_DIR/pkglist.txt"
echo "  $OUT_DIR/aur-pkglist.txt"
echo "  $OUT_DIR/pkglist-all.txt"
