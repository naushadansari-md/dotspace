-------------------------------------------------------
-- Gestures
-------------------------------------------------------

-- macOS-style workspace switching
hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
    scale = 0.9,
})

-- Three-finger vertical scrolling
hl.gesture({
    fingers = 3,
    direction = "vertical",
    action = "scroll_move",
    scale = 0.9,
})

-- Fullscreen on
hl.gesture({
    fingers = 2,
    direction = "pinchout",
    action = function()
        hl.dispatch(hl.dsp.window.fullscreen({ action = "set" }))
    end
})

-- Fullscreen off
hl.gesture({
    fingers = 2,
    direction = "pinchin",
    action = function()
        hl.dispatch(hl.dsp.window.fullscreen({ action = "unset" }))
    end
})