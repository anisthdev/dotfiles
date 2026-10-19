-- Material 3 Expressive motion: https://m3.material.io/styles/motion/overview/how-it-works
-- springs from Compose's MotionScheme.expressive(). M3 gives a damping ratio, hyprland wants
-- the damping coefficient, which is 2 * ratio * sqrt(stiffness * mass).
-- spatial springs (position, size) bounce a little, effects springs (opacity) never do.
hl.curve("spatialFast", { type = "spring", mass = 1, stiffness = 800, dampening = 33.94 }) -- ratio 0.6
hl.curve("spatialDefault", { type = "spring", mass = 1, stiffness = 380, dampening = 31.19 }) -- ratio 0.8
hl.curve("spatialSlow", { type = "spring", mass = 1, stiffness = 200, dampening = 22.63 }) -- ratio 0.8
hl.curve("effectsFast", { type = "spring", mass = 1, stiffness = 3800, dampening = 123.29 }) -- ratio 1
hl.curve("effectsDefault", { type = "spring", mass = 1, stiffness = 1600, dampening = 80 }) -- ratio 1

-- windows pop out of their spot and overshoot a touch, then shrink away without bouncing
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.0, spring = "spatialDefault", style = "popin 80%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4.0, spring = "effectsDefault", style = "popin 80%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4.0, spring = "spatialFast", style = "slide" })

hl.animation({ leaf = "fade", enabled = true, speed = 4.0, spring = "effectsDefault" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 4.0, spring = "effectsFast" })
hl.animation({ leaf = "fadePopupsOut", enabled = true, speed = 4.0, spring = "effectsFast" })

-- bars, menus and notifications spring in from their edge
hl.animation({ leaf = "layersIn", enabled = true, speed = 4.0, spring = "spatialDefault", style = "slide" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 4.0, spring = "effectsFast", style = "slide" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 4.0, spring = "effectsFast" })

hl.animation({ leaf = "workspaces", enabled = true, speed = 4.0, spring = "spatialDefault", style = "slidevert" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4.0, spring = "spatialSlow", style = "slidevert 70%" })

hl.animation({ leaf = "zoomFactor", enabled = true, speed = 4.0, spring = "spatialDefault" })
