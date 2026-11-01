-- ============================================================
-- Input Configuration
-- ============================================================

-- ------------------------------------------------------------
-- Device Overrides
-- ------------------------------------------------------------

-- External USB Mouse (Dell MS116)
hl.device({
    name = "pixart-dell-ms116-usb-optical-mouse",
    sensitivity = -0.3,
})

-- Internal Touchpad
hl.device({
    name = "elan0791:00-04f3:30fd-touchpad",
    sensitivity = 0.2,
})

-- ------------------------------------------------------------
-- Main Input Settings
-- ------------------------------------------------------------
hl.config({
    input = {
        -- Keyboard
        kb_layout = "us",
        numlock_by_default = true,
        repeat_rate = 35,
        repeat_delay = 250,

        -- Mouse Behavior
        follow_mouse = 1,
        mouse_refocus = false,
        sensitivity = 0.0,

        -- Touchpad
        touchpad = {
            natural_scroll = false,
            scroll_factor = 0.8,
            disable_while_typing = true,
            tap_to_click = true,
            clickfinger_behavior = true, -- Makes 1, 2, and 3 finger clicks reliable
            tap_and_drag = true,
        },
    },
})