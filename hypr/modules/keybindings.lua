-- ============================================================
-- Variables
-- ============================================================

local mainMod = "SUPER"
local scriptDir = "~/.config/hypr/scripts"

-- Applications
local terminal = "foot --class FloatTerm"
local editor = "code"
local filemanger = "thunar"
local launcher = "bash -lc \"~/.config/hypr/scripts/dock-launcher-exec.sh nwg-drawer -ovl -c 7\""
local browser = "firefox"

-- ============================================================
-- Window / Session Actions
-- ============================================================

-- Reload Hyprland config
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))

-- Close focused window (clean)
hl.bind(mainMod .. " + Q", hl.dsp.window.close())

-- Force-kill focused window (needs jq)
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd("hyprctl activewindow -j | jq -r '.pid' | xargs -r kill"))

-- Fullscreen (two modes)
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + M", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))

-- Toggle floating
hl.bind(mainMod .. " + W", hl.dsp.window.float({ action = "toggle" }))

-- Group
hl.bind(mainMod .. " + G", hl.dsp.group.toggle())

-- Lock
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd(scriptDir .. "/lock.sh"))

-- Exit Hyprland (proper)
hl.bind(mainMod .. " + Backspace", hl.dsp.exit())
hl.bind("CTRL + ALT + Backspace", hl.dsp.exit())

-- Waybar
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("pkill -SIGUSR2 waybar"))

-- Notifications
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -t"))

-- Wallpaper
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd(scriptDir .. "/set-wallpaper.sh"))

-- System Menu
hl.bind(mainMod .. " + ESCAPE", hl.dsp.exec_cmd("~/.config/waybar/scripts/system-menu.sh"))

-- ============================================================
-- Application Shortcuts
-- ============================================================

hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(editor))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(filemanger))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd("kitty -e yazi"))

-- Launchers
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(launcher))

-- ============================================================
-- Workspace Navigation
-- ============================================================

hl.bind(mainMod .. " + Tab", hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.focus({ workspace = "m-1" }))

hl.bind(mainMod .. " + 1", hl.dsp.focus({ workspace = 1 }))
hl.bind(mainMod .. " + 2", hl.dsp.focus({ workspace = 2 }))
hl.bind(mainMod .. " + 3", hl.dsp.focus({ workspace = 3 }))
hl.bind(mainMod .. " + 4", hl.dsp.focus({ workspace = 4 }))
hl.bind(mainMod .. " + 5", hl.dsp.focus({ workspace = 5 }))
hl.bind(mainMod .. " + 6", hl.dsp.focus({ workspace = 6 }))
hl.bind(mainMod .. " + 7", hl.dsp.focus({ workspace = 7 }))
hl.bind(mainMod .. " + 8", hl.dsp.focus({ workspace = 8 }))
hl.bind(mainMod .. " + 9", hl.dsp.focus({ workspace = 9 }))
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))

hl.bind(mainMod .. " + CTRL + right", hl.dsp.focus({ workspace = "r+1" }))
hl.bind(mainMod .. " + CTRL + left", hl.dsp.focus({ workspace = "r-1" }))
hl.bind(mainMod .. " + CTRL + down", hl.dsp.focus({ workspace = "empty" }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- ============================================================
-- Move Windows Between Workspaces
-- ============================================================

hl.bind(mainMod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))
hl.bind(mainMod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }))
hl.bind(mainMod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }))
hl.bind(mainMod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }))
hl.bind(mainMod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }))
hl.bind(mainMod .. " + SHIFT + 6", hl.dsp.window.move({ workspace = 6 }))
hl.bind(mainMod .. " + SHIFT + 7", hl.dsp.window.move({ workspace = 7 }))
hl.bind(mainMod .. " + SHIFT + 8", hl.dsp.window.move({ workspace = 8 }))
hl.bind(mainMod .. " + SHIFT + 9", hl.dsp.window.move({ workspace = 9 }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

hl.bind(mainMod .. " + CTRL + ALT + right", hl.dsp.window.move({ workspace = "r+1" }))
hl.bind(mainMod .. " + CTRL + ALT + left", hl.dsp.window.move({ workspace = "r-1" }))

hl.bind(mainMod .. " + ALT + 1", hl.dsp.window.move({ workspace = 1, follow = false }))
hl.bind(mainMod .. " + ALT + 2", hl.dsp.window.move({ workspace = 2, follow = false }))
hl.bind(mainMod .. " + ALT + 3", hl.dsp.window.move({ workspace = 3, follow = false }))
hl.bind(mainMod .. " + ALT + 4", hl.dsp.window.move({ workspace = 4, follow = false }))
hl.bind(mainMod .. " + ALT + 5", hl.dsp.window.move({ workspace = 5, follow = false }))
hl.bind(mainMod .. " + ALT + 6", hl.dsp.window.move({ workspace = 6, follow = false }))
hl.bind(mainMod .. " + ALT + 7", hl.dsp.window.move({ workspace = 7, follow = false }))
hl.bind(mainMod .. " + ALT + 8", hl.dsp.window.move({ workspace = 8, follow = false }))
hl.bind(mainMod .. " + ALT + 9", hl.dsp.window.move({ workspace = 9, follow = false }))
hl.bind(mainMod .. " + ALT + 0", hl.dsp.window.move({ workspace = 10, follow = false }))

-- ============================================================
-- Focus & Window Movement
-- ============================================================

hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))
hl.bind("ALT + Tab", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + SHIFT + CTRL + left", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + CTRL + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + CTRL + up", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + CTRL + down", hl.dsp.window.move({ direction = "d" }))

-- ============================================================
-- Resize Windows
-- ============================================================

hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.resize({ x = 30, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.resize({ x = -30, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.resize({ x = 0, y = -30, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.resize({ x = 0, y = 30, relative = true }), { repeating = true })

-- ============================================================
-- Mouse Window Controls
-- ============================================================

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag())
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize())
hl.bind(mainMod .. " + Z", hl.dsp.window.drag())

-- ============================================================
-- Special Workspace (Scratchpad)
-- ============================================================

hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special", follow = false }))
hl.bind(mainMod .. " + J", hl.dsp.workspace.toggle_special(""))

-- ============================================================
-- Layout Toggle
-- ============================================================

hl.bind(mainMod .. " + T", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + S", hl.dsp.layout("swapsplit"))

-- ============================================================
-- Multimedia Keys
-- ============================================================

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(scriptDir .. "/system-osd.sh volume --inc"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(scriptDir .. "/system-osd.sh volume --dec"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(scriptDir .. "/system-osd.sh volume --mute"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(scriptDir .. "/system-osd.sh brightness --inc"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(scriptDir .. "/system-osd.sh brightness --dec"), { locked = true, repeating = true })

hl.bind("XF86KbdBrightnessUp", hl.dsp.exec_cmd("light -s sysfs/leds/smc::kbd_backlight -A 5"), { locked = true, repeating = true })
hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd("light -s sysfs/leds/smc::kbd_backlight -U 5"), { locked = true, repeating = true })

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- ============================================================
-- Screenshots
-- ============================================================

hl.bind("SUPER + SHIFT + 3", hl.dsp.exec_cmd("sh -c 'mkdir -p ~/Pictures/Screenshots; FILE=~/Pictures/Screenshots/Screenshot-$(date +%F_%T).png; grim - | tee \"$FILE\" | wl-copy && notify-send -i \"$FILE\" \"Screenshot\" \"Full screen captured\" -t 1000'"))
hl.bind("SUPER + SHIFT + 4", hl.dsp.exec_cmd("sh -c 'mkdir -p ~/Pictures/Screenshots; FILE=~/Pictures/Screenshots/Screenshot-$(date +%F_%T).png; grim -g \"$(slurp)\" | tee >(wl-copy) | { cat > \"$FILE\" && [ -s \"$FILE\" ] && notify-send -i \"$FILE\" \"Screenshot\" \"Region captured\" -t 1000 || rm -f \"$FILE\"; }'"))
hl.bind("SUPER + SHIFT + 5", hl.dsp.exec_cmd("sh -c 'grim -g \"$(slurp)\" | swappy -f -'"))
