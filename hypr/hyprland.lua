-- ============================================================
-- Hyprland Main Configuration
-- ============================================================

-- ------------------------------------------------------------
-- System & Environment
-- ------------------------------------------------------------
require("modules.monitors")
require("modules.autostart")
require("modules.env")

-- ------------------------------------------------------------
-- Visuals & Themes
-- ------------------------------------------------------------
require("modules.appearance")
require("modules.decorations")
require("modules.animations")

-- ------------------------------------------------------------
-- Inputs, Settings & Binds
-- ------------------------------------------------------------
require("modules.inputs")
require("modules.gestures")
require("modules.settings")
require("modules.keybindings")
require("modules.windowrules")