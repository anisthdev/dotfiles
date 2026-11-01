-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
hl.on("hyprland.start", function()
	-- The wallpaper daemon (awww-daemon), once quickbar has locked
	hl.exec_cmd("uwsm app -- /usr/lib/quickbar/boot")
	-- The shell (bar, notifications, menus, lock screen, polkit agent) is
	-- quickbar.service, enabled for graphical-session.target: locked from
	-- the start, and restarted, locked again, if it crashes
	hl.exec_cmd("uwsm app -- hypridle")
	hl.exec_cmd("clipse -listen")
	hl.exec_cmd("hyprpm reload")
end)
