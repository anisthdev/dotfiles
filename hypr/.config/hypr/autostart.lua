-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
hl.on("hyprland.start", function()
	-- The shell: bar, notifications, menus, lock screen and polkit agent
	hl.exec_cmd("uwsm app -- qs -p $HOME/Projects/quickbar")
	-- Locked from the start: as soon as quickbar answers (up to 10 s)
	hl.exec_cmd("sh -c 'for _ in $(seq 100); do qs -p $HOME/Projects/quickbar ipc call lock lock 2>/dev/null && exit; sleep 0.1; done'")
	hl.exec_cmd("uwsm app -- hypridle")
	hl.exec_cmd("uwsm app -- awww-daemon")
	hl.exec_cmd("clipse -listen")
	hl.exec_cmd("hyprpm reload")
end)
