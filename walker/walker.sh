#!/usr/bin/env bash
set -euo pipefail

# Ensure elephant user service is running
systemctl --user start elephant.service >/dev/null 2>&1 || true

# Wait briefly until elephant responds (max ~1s)
for _ in {1..10}; do
  elephant providers list >/dev/null 2>&1 && break
  sleep 0.1
done

# Theme (optional)
theme_file="$HOME/.config/walker/walker-theme"
if [ -f "$theme_file" ]; then
  walker_theme="$(cat "$theme_file")"
  exec walker -t "$walker_theme" "$@"
else
  exec walker "$@"
fi
