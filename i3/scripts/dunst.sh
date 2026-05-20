#!/bin/sh

# 1. Symlink the Pywal-generated dunst config cleanly
ln -sf ~/.cache/wal/dunstrc ~/.config/dunst/dunstrc

# 2. Tell DBus about your current display environment variables
dbus-update-activation-environment --systemd DISPLAY XAUTHORITY WAYLAND_DISPLAY

# 3. Let systemd handle the restart so it reads the new symlinked config 
#    without losing its DBus connection tracking!
systemctl --user restart dunst.service
