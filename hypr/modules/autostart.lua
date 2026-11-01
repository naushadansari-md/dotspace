-- ============================================================
-- Script Directory & Paths
-- ============================================================

local home = os.getenv("HOME")
local scriptDir = home .. "/.config/hypr/scripts/"

-- ============================================================
-- Autostart Applications & Initialization
-- ============================================================

hl.on("hyprland.start", function()
    -- 1. FIRST: Update D-Bus and Systemd environment variables 
    -- so all subsequent daemons and apps inherit them properly.
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    -- 2. Authentication & Core Daemons
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("swaync")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("udiskie --no-automount --smart-tray")
    hl.exec_cmd("light -s sysfs/leds/smc::kbd_backlight -S 20")

    -- 3. Status Bar (Using safe absolute path instead of ~)
    hl.exec_cmd(home .. "/.config/waybar/scripts/waybar-launch.sh")

    -- 4. Custom Scripts
    hl.exec_cmd(scriptDir .. "/welcome.sh")
    hl.exec_cmd(scriptDir .. "/hyprlock.sh")
    hl.exec_cmd(scriptDir .. "/battery-monitor.sh")
    hl.exec_cmd(scriptDir .. "/hypridle-power.sh")
    hl.exec_cmd(scriptDir .. "/start-dock.sh")
    hl.exec_cmd(scriptDir .. "/dock-controller.sh")
    hl.exec_cmd(scriptDir .. "/set-wallpaper.sh")
    hl.exec_cmd(scriptDir .. "/dock-launcher.sh")
end)