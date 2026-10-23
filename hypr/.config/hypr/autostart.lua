-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
hl.on("hyprland.start", function()
	-- The wallpaper daemon (awww-daemon), once quickbar has locked
	hl.exec_cmd("uwsm app -- $HOME/Projects/quickbar/scripts/boot")
	-- The shell: bar, notifications, menus, lock screen and polkit agent;
	-- locked from the start (QUICKBAR_BOOT)
	hl.exec_cmd("uwsm app -- env QUICKBAR_BOOT=1 qs -p $HOME/Projects/quickbar")
	hl.exec_cmd("uwsm app -- hypridle")
	hl.exec_cmd("clipse -listen")
	hl.exec_cmd("hyprpm reload")
end)
