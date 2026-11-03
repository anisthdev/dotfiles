-- Material 3 motion: https://m3.material.io/styles/motion/overview/how-it-works
-- springs from Compose's MotionScheme. M3 gives a damping ratio, hyprland wants the
-- damping coefficient, which is 2 * ratio * sqrt(stiffness * mass).
--
-- one rule for the whole desktop:
--   things you summon (a window, a scratchpad, a bar or notification) come in on an
--   expressive spring and overshoot a touch, so the arrival reads.
--   things you do all the time (scrolling the strip, switching workspaces, zooming)
--   use the standard scheme: quick, and they settle without a wobble.
--   things leaving never bounce, and go faster than they came.
--   opacity is always critically damped.

-- expressive spatial: summoned surfaces
hl.curve("expressiveDefault", { type = "spring", mass = 1, stiffness = 380, dampening = 31.19 }) -- ratio 0.8
-- standard spatial: navigation
hl.curve("standardFast", { type = "spring", mass = 1, stiffness = 1400, dampening = 67.35 }) -- ratio 0.9
hl.curve("standardDefault", { type = "spring", mass = 1, stiffness = 700, dampening = 47.62 }) -- ratio 0.9
-- effects: opacity and exits
hl.curve("effectsFast", { type = "spring", mass = 1, stiffness = 3800, dampening = 123.29 }) -- ratio 1
hl.curve("effectsDefault", { type = "spring", mass = 1, stiffness = 1600, dampening = 80 }) -- ratio 1

local function anim(leaf, spring, style)
	hl.animation({ leaf = leaf, enabled = true, speed = 4.0, spring = spring, style = style })
end

-- windows grow out of their spot; on close they shrink a little less and quicker
anim("windowsIn", "expressiveDefault", "popin 80%")
anim("windowsOut", "effectsFast", "popin 90%")
-- the scrolling strip moves on every focus change, so no overshoot here
anim("windowsMove", "standardFast", "slide")

-- every fade (popups, shadows, dim, screen blanking) settles on this unless set below
anim("fade", "effectsDefault")
anim("fadeOut", "effectsFast")
anim("fadePopupsOut", "effectsFast")

-- bars, menus and notifications spring in from their edge and slip back out
anim("layersIn", "expressiveDefault", "slide")
anim("layersOut", "effectsFast", "slide")
anim("fadeLayersOut", "effectsFast")

-- a full-screen surface overshooting is a lot of moving pixels; workspaces glide and stop
anim("workspaces", "standardDefault", "slidevert")
-- scratchpads are summoned, so they get the spring, but only a short rise with a fade
-- rather than a trip across the whole screen
anim("specialWorkspaceIn", "expressiveDefault", "slidefadevert 30%")
anim("specialWorkspaceOut", "effectsFast", "slidefadevert 30%")

anim("zoomFactor", "standardDefault")
