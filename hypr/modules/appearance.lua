-- ============================================================
-- GTK Theme & Icons
-- ============================================================

hl.on("config.reloaded", function()
    -- Appearance & Colorscheme
    hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-olive'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface icon-theme 'Yaru-olive'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")

    -- Synchronized Cursor Settings (Using Bibata-Modern-Ice as an example)
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 24")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size 24")

    -- Fonts & Antialiasing
    hl.exec_cmd("gsettings set org.gnome.desktop.interface font-name 'Fira Sans 10.5'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface document-font-name 'Fira Sans 10.5'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 10.5'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface font-antialiasing 'rgba'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface font-hinting 'full'")
end)