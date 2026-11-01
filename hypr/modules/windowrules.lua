-- ============================================================
-- Window Rules & Layer Rules
-- ============================================================

-- ============================================================
-- Floating Rules
-- ============================================================

-- Float modal dialogs
hl.window_rule({
    match = {
        modal = 1,
    },
    float = true,
})

-- PulseAudio Volume Control
hl.window_rule({
    match = {
        class = "^(org\\.pulseaudio\\.pavucontrol)$",
    },
    float = true,
    size = "700 550",
})

-- Bluetooth Manager
hl.window_rule({
    match = {
        class = "^(blueman-manager)$",
    },
    float = true,
    size = "700 550",
})

-- XDG Portals
hl.window_rule({
    match = {
        class = "^(xdg-desktop-portal-gtk|xdg-desktop-portal-kde|xdg-desktop-portal-hyprland)(.*)$",
    },
    float = true,
})

-- Polkit agents
hl.window_rule({
    match = {
        class = "^(polkit-gnome-authentication-agent-1|hyprpolkitagent)(.*)$",
    },
    float = true,
})

-- Theme tools
hl.window_rule({
    match = {
        class = "^(nwg-look|qt5ct|qt6ct|kvantummanager)$",
    },
    float = true,
    size = "700 550",
})

-- Enpass
hl.window_rule({
    match = {
        class = "^(Enpass)$",
    },
    float = true,
    size = "1000 650",
})

-- Telegram
hl.window_rule({
    match = {
        class = "^(org.telegram.desktop)$",
    },
    float = true,
    size = "1230 700",
})

-- btop terminal
hl.window_rule({
    match = {
        class = "^(btopterm)$",
    },
    float = true,
})

-- OneDrive Tray
hl.window_rule({
    match = {
        class = "^(onedrive_tray)$",
    },
    float = true,
})

-- Special floating terminal class
hl.window_rule({
    match = {
        class = "^(FloatTerm)$",
    },
    float = true,
    size = { 900, 650 },
    center = true,
    "suppressmaximize",
})

-- ============================================================
-- File Dialogs & Progress Windows
-- ============================================================

-- Common file dialogs
hl.window_rule({
    match = {
        title = "^(Save File|Open File|Choose Files|Save As|Confirm to replace files)$",
    },
    float = true,
})

-- File Operation Progress (Nemo / Thunar / etc.)
hl.window_rule({
    match = {
        title = "^(File Operation Progress)$",
    },
    float = true,
    size = "420 140",
    move = "20 20",
})

-- Nemo Properties dialog
hl.window_rule({
    match = {
        class = "^(nemo)$",
        title = "^(.* Properties)$",
    },
    float = true,
    center = true,
    size = "600 500",
})

-- Archive Manager (File Roller)
hl.window_rule({
    match = {
        class = "^(org\\.gnome\\.FileRoller)$",
    },
    float = true,
    center = true,
    size = "700 550",
})

hl.window_rule({
    match = {
        class = "^(org\\.gnome\\.FileRoller)$",
        title = "^(Extract|Compress)$",
    },
    float = true,
    center = true,
    size = "700 550",
})

-- Rename dialogs
hl.window_rule({
    match = {
        title = '^Rename "(.*)"$',
    },
    float = true,
})

-- ============================================================
-- Picture-in-Picture
-- ============================================================

hl.window_rule({
    match = {
        title = "^(Picture-in-Picture|Picture in picture|Picture in Picture)$",
    },
    float = true,
    size = "960 540",
    move = "0 100%-",
})

-- ============================================================
-- Opacity Rules
-- ============================================================

-- File managers
hl.window_rule({
    match = {
        class = "^(thunar|nemo|cosmic-files)$",
    },
    opacity = 0.90,
})

hl.window_rule({
    match = {
        class = "^(org.gnome.FileRoller)$",
    },
    opacity = 0.90,
})

-- Apps
hl.window_rule({
    match = {
        class = "^(kitty|geany|Alacritty|nwg-look|Enpass|org\\.mozilla\\.Thunderbird|blueman-manager|imv|org.telegram.desktop|btop)$",
    },
    opacity = 0.90,
})

hl.window_rule({
    match = {
        class = "^(jetbrains-idea-ce|qt6ct)$",
    },
    opacity = 0.90,
})

hl.window_rule({
    match = {
        class = "^(google-chrome|firefox)$",
    },
    opacity = 0.95,
})

hl.window_rule({
    match = {
        class = "^(org\\.pwmt\\.zathura)$",
    },
    opacity = 0.90,
})

hl.window_rule({
    match = {
        class = "^(code)$",
    },
    opacity = 0.95,
})

-- Dialogs & Portals
hl.window_rule({
    match = {
        title = "^(polkit-gnome-authentication-agent-1)$",
    },
    opacity = 0.90,
})

hl.window_rule({
    match = {
        title = "^(org\\.freedesktop\\.impl\\.portal\\.desktop\\.gtk)$",
    },
    opacity = 0.90,
})

hl.window_rule({
    match = {
        title = "^(org\\.freedesktop\\.impl\\.portal\\.desktop\\.hyprland)$",
    },
    opacity = 0.90,
})

hl.window_rule({
    match = {
        title = "^(org\\.pulseaudio\\.pavucontrol)$",
    },
    opacity = 0.90,
})

-- Special floating terminal opacity
hl.window_rule({
    match = {
        class = "^(FloatTerm)$",
    },
    opacity = 0.90,
})

-- ============================================================
-- Layer Rules (Blur Effects & Overlays)
-- ============================================================

-- Fuzzel
hl.layer_rule({
    match = { namespace = "launcher" },
    blur = true,
    ignore_alpha = 0.2,
})

-- Waybar
hl.layer_rule({
    match = { namespace = "waybar" },
    blur = true,
    ignore_alpha = 1,
})

-- Rofi
hl.layer_rule({
    match = { namespace = "rofi" },
    blur = true,
    ignore_alpha = 0.2,
})

-- SwayNC Control Center
hl.layer_rule({
    match = { namespace = "swaync-control-center" },
    blur = true,
    ignore_alpha = 0.2,
})

-- SwayNC Notification Popups
hl.layer_rule({
    match = { namespace = "swaync-notification-window" },
    blur = true,
    ignore_alpha = 0.2,
})

-- nwg-drawer
hl.layer_rule({
    match = { namespace = "nwg-drawer" },
    blur = true,
    ignore_alpha = 0.2,
})