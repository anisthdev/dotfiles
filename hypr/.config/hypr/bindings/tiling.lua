local mainMod = "SUPER + "

-- Window management
hl.bind(mainMod .. "W", hl.dsp.window.close(), { description = "Close window" })
hl.bind(mainMod .. "P", hl.dsp.window.pseudo(), { description = "Toggle pseudotile" })
hl.bind(mainMod .. "SHIFT + V", hl.dsp.window.float(), { description = "Toggle float" })
hl.bind("F11", hl.dsp.window.fullscreen(), { description = "Toggle fullscreen" })

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }), { description = "Focus left" })
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }), { description = "Focus right" })
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }), { description = "Focus up" })
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }), { description = "Focus down" })

-- Switch workspaces with mainMod + [1-9]
-- Move active window to a workspace with mainMod + SHIFT + [1-9]
for i = 1, 9 do
	hl.bind(mainMod .. i, hl.dsp.focus({ workspace = i }), { description = "Focus workspace " .. i })
	hl.bind(
		mainMod .. "SHIFT + " .. i,
		hl.dsp.window.move({ workspace = i }),
		{ description = "Move window to workspace " .. i }
	)
end

-- Swap windows with mainMod + SHIFT + arrow keys
hl.bind(mainMod .. "SHIFT + left", hl.dsp.window.swap({ direction = "left" }), { description = "Swap with left" })
hl.bind(mainMod .. "SHIFT + right", hl.dsp.window.swap({ direction = "right" }), { description = "Swap with right" })
hl.bind(mainMod .. "SHIFT + up", hl.dsp.window.swap({ direction = "up" }), { description = "Swap with up" })
hl.bind(mainMod .. "SHIFT + down", hl.dsp.window.swap({ direction = "down" }), { description = "Swap with down" })

--swap workspaces between monitors
hl.bind(mainMod .. "CTRL + S", hl.dsp.workspace.move({ monitor = "+1" }), { description = "Swap workspace" })

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
