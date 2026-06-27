hl.window_rule({ name = "suppress-maximize-events", match = { class = ".*" }, suppress_event = "maximize" })

-- Fix some dragging issues with XWayland
hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},

	no_focus = true,
})

-- set full opacity for focused video players
local videoPlayers = "mpv|vlc|chrome-netflix.com__-Default"
hl.window_rule({ match = { class = videoPlayers }, opacity = "1.0 override 0.88" })

-- floating windows
hl.window_rule({ match = { class = "xdg-desktop-portal-gtk" }, float = true, size = { "900", "500" }, animation = "gnomed", })
hl.window_rule({ match = { class = "thunar", title = "Rename.*" }, float = true, size = { "500", "80" }, animation = "gnomed", })
hl.window_rule({ match = { class = "clipse-gui" }, float = true, size = { "500", "600" }, animation = "gnomed" })
hl.window_rule({ match = { class = "localsend" }, float = true, size = { "500", "700" }, animation = "gnomed" })
hl.window_rule({ match = { class = "nwg-look" }, float = true, size = { "500", "700" }, animation = "gnomed" })

-- pseudo floating windows
hl.window_rule({ match = { class = "firefox" }, pseudo = true, size = { "monitor_w * 0.65", "monitor_h" } })
hl.window_rule({ match = { tag = "noop" }, opacity = "1.0 override 0.88" })
