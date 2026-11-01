-- ============================================================
-- Animations & Bezier Curves
-- ============================================================

-- ------------------------------------------------------------
-- Bezier Curves
-- ------------------------------------------------------------
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

-- ------------------------------------------------------------
-- Core Animations (Balanced & Smooth)
-- ------------------------------------------------------------

-- Global
hl.animation({
    leaf = "global",
    enabled = true,
    speed = 8,
    bezier = "default",
})

-- Borders
hl.animation({
    leaf = "border",
    enabled = true,
    speed = 4.5,
    bezier = "easeOutQuint",
})

-- Windows (Smooth in, faster out)
hl.animation({
    leaf = "windows",
    enabled = true,
    speed = 4.2,
    bezier = "easeOutQuint",
})
hl.animation({
    leaf = "windowsIn",
    enabled = true,
    speed = 4.8,
    bezier = "easeOutQuint",
    style = "popin 87%",
})
hl.animation({
    leaf = "windowsOut",
    enabled = true,
    speed = 2.2,
    bezier = "quick",
    style = "popin 87%",
})

-- Fade (Consistent)
hl.animation({
    leaf = "fade",
    enabled = true,
    speed = 3.2,
    bezier = "almostLinear",
})
hl.animation({
    leaf = "fadeIn",
    enabled = true,
    speed = 2.0,
    bezier = "almostLinear",
})
hl.animation({
    leaf = "fadeOut",
    enabled = true,
    speed = 1.8,
    bezier = "almostLinear",
})

-- Layers (Menus, launchers, overlays)
hl.animation({
    leaf = "layers",
    enabled = true,
    speed = 4.0,
    bezier = "easeOutQuint",
})
hl.animation({
    leaf = "layersIn",
    enabled = true,
    speed = 4.6,
    bezier = "easeOutQuint",
    style = "fade",
})
hl.animation({
    leaf = "layersOut",
    enabled = true,
    speed = 2.6,
    bezier = "quick",
    style = "fade",
})
hl.animation({
    leaf = "fadeLayersIn",
    enabled = true,
    speed = 2.0,
    bezier = "almostLinear",
})
hl.animation({
    leaf = "fadeLayersOut",
    enabled = true,
    speed = 1.8,
    bezier = "almostLinear",
})

-- Workspaces (Smooth & readable)
hl.animation({
    leaf = "workspaces",
    enabled = true,
    speed = 2.6,
    bezier = "easeInOutCubic",
    style = "fade",
})
hl.animation({
    leaf = "workspacesIn",
    enabled = true,
    speed = 2.4,
    bezier = "easeInOutCubic",
    style = "fade",
})
hl.animation({
    leaf = "workspacesOut",
    enabled = true,
    speed = 2.4,
    bezier = "easeInOutCubic",
    style = "fade",
})

-- Zoom (Keep it snappy)
hl.animation({
    leaf = "zoomFactor",
    enabled = true,
    speed = 6.0,
    bezier = "quick",
})

-- ------------------------------------------------------------
-- Config Block
-- ------------------------------------------------------------
hl.config({
    animations = {
        enabled = true,
    },
})