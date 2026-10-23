hl.config({
	general = {
		gaps_in = 2,
		gaps_out = 5,
		border_size = 0,
		resize_on_border = false,
		allow_tearing = false,
		layout = "scrolling",
	},

	decoration = {
		rounding = 12,
		rounding_power = 5,
		active_opacity = 0.90,
		inactive_opacity = 0.88,
		shadow = {
			enabled = true,
			range = 22,
			render_power = 2,
			color = 0x88000000,
		},
		blur = {
			enabled = true,
			size = 8,
			passes = 4,
			vibrancy = 0.3,
			vibrancy_darkness = 0.5,
			noise = 0.1,
			popups = true,
		},
	},
	animations = {
		enabled = true,
		workspace_wraparound = true,
	},
	misc = {
		-- Plain black under everything: at login, between the boot splash
		-- and the lock screen, nothing else shows
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		background_color = 0xff000000,
		allow_session_lock_restore = true, -- lets a new lock screen take over if the old one dies
		key_press_enables_dpms = true, -- any key wakes a blanked screen
		mouse_move_enables_dpms = true,
	},
})

-- blur for quickbar (and its full-screen overlays) and its notifications
hl.layer_rule({
	match = { namespace = "quickbar|quickbar-overlay|notifications" },
	blur = true,
	ignore_alpha = 0.2,
	blur_popups = true,
})

-- no animation for these layers, since they are used for popups and selection and stuff
hl.layer_rule({ match = { namespace = "glint|selection|hyprpicker" }, no_anim = true })
-- quickbar's full-screen overlays animate themselves; a layer slide would
-- carry the whole screen-sized surface off
hl.layer_rule({ match = { namespace = "quickbar-overlay|quickbar-dialog" }, no_anim = true })
