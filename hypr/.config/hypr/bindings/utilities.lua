local mainMod = "SUPER + "
local scriptDir = os.getenv("HOME") .. "/.local/bin/"

-- quickbar's windows, through its IPC
local quickbar = "qs -p $HOME/Projects/quickbar ipc call "
local function shell(call)
	return hl.dsp.exec_cmd(quickbar .. call)
end

--launching
hl.bind(mainMod .. "B", hl.dsp.exec_cmd("uwsm app -- firefox -P asif"), { description = "Browser" })
hl.bind(mainMod .. "Return", hl.dsp.exec_cmd("uwsm app -- ghostty"), { description = "Terminal" })
hl.bind(mainMod .. "Y", hl.dsp.exec_cmd("uwsm app -- ghostty --title=yazi -e yazi"), { description = "Yazi" })
hl.bind(mainMod .. "SHIFT + B", hl.dsp.exec_cmd("uwsm app -- firefox --private-window"), { description = "Incognito" })
hl.bind("XF86Calculator", shell("calculator toggle"), { description = "Calculator" })
hl.bind("XF86Explorer", hl.dsp.exec_cmd("uwsm app -- nautilus"), { description = "File manager" })
hl.bind("XF86HomePage", shell("launcher toggle"), { description = "App launcher" })
hl.bind("XF86Mail", hl.dsp.exec_cmd("uwsm app -- firefox -P asif https://mail.google.com"), { description = "Gmail" })
hl.bind("XF86Tools", shell("musicmenu toggle"), { description = "Music library" })
hl.bind(mainMod .. "V", shell("clipboard toggle"), { description = "Clipboard manager" })

--Toggle switches
hl.bind(mainMod .. "SHIFT + SPACE", shell("bar toggle"), { description = "Toggle bar" })
hl.bind(mainMod .. "comma", shell("notifications dismiss"), { description = "Close notification" })
hl.bind(mainMod .. "CTRL + I", shell("keepawake toggle"), { description = "Keep awake" })

-- The touchpad key (F21); back on with a config reload
local touchpadOn = true
hl.bind("XF86TouchpadToggle", function()
	touchpadOn = not touchpadOn
	hl.device({ name = "asue1300:00-04f3:3104-touchpad", enabled = touchpadOn })
	hl.exec_cmd(
		"notify-send -a Touchpad -i input-touchpad-symbolic -h string:x-canonical-private-synchronous:touchpad Touchpad "
			.. (touchpadOn and "On" or "Off")
	)
end, { description = "Toggle touchpad" })
hl.bind("XF86WebCam", hl.dsp.exec_cmd(scriptDir .. "webcam-toggle"), { description = "Toggle webcam" })

--menus
hl.bind(mainMod .. "SPACE", shell("launcher toggle"), { description = "App launcher" })
hl.bind(mainMod .. "Q", shell("controlpanel toggle"), { description = "Control Panel" })
hl.bind(mainMod .. "E", shell("entertainment toggle"), { description = "Entertainment" })
hl.bind(mainMod .. "M", shell("reelmenu toggle"), { description = "Video library" })
hl.bind(mainMod .. "SHIFT + M", shell("musicmenu toggle"), { description = "Music library" })
hl.bind(mainMod .. "R", shell("games toggle"), { description = "RetroArch NES" })
hl.bind(mainMod .. "CTRL + SPACE", shell("wallpaper toggle"), { description = "Wallpaper picker" })
hl.bind(mainMod .. "ESCAPE", shell("power toggle"), { description = "Power menu" })
hl.bind(mainMod .. "CTRL + N", shell("glyphs toggle"), { description = "Glyph selector" })
hl.bind(mainMod .. "period", shell("emoji toggle"), { description = "Emoji picker" })
hl.bind(mainMod .. "CTRL + V", shell("search open play"), { description = "Play video from URL" })
hl.bind(mainMod .. "SHIFT + N", shell("note toggle"), { description = "Quick note to inbox" })
hl.bind(mainMod .. "SHIFT + T", shell("tasks toggle"), { description = "To-do list" })
hl.bind(mainMod .. "CTRL + K", shell("keybindings toggle"), { description = "Keybindings" })
-- Seedling (~/Projects/seedling), its own Quickshell config: toggled
-- through its IPC, or started (it opens on starting) when not running
hl.bind(mainMod .. "T", hl.dsp.exec_cmd("qs -p $HOME/Projects/seedling ipc call seedling toggle || uwsm app -- qs -p $HOME/Projects/seedling"), { description = "Torrents" })
hl.bind("PRINT", shell("screenshot toggle"), { description = "Screenshot" })
hl.bind("ALT + PRINT", shell("record toggle"), { description = "Screenrecord" })

-- Hindi films, kept off the entertainment menu
hl.bind(mainMod .. "SHIFT + E", shell("search open hindi"))

--bar menus
hl.bind(mainMod .. "ALT + W", shell("wifi toggle"), { description = "Wi-Fi menu" })
hl.bind(mainMod .. "ALT + B", shell("bluetooth toggle"), { description = "Bluetooth menu" })
hl.bind(mainMod .. "ALT + A", shell("audio toggle"), { description = "Sound menu" })
hl.bind(mainMod .. "ALT + C", shell("calendar toggle"), { description = "Calendar" })
hl.bind(mainMod .. "ALT + M", shell("media toggle"), { description = "Now playing" })
hl.bind(mainMod .. "ALT + D", shell("downloads toggle"), { description = "Downloads" })
hl.bind(mainMod .. "ALT + P", shell("battery toggle"), { description = "Battery and power profile" })

--others
hl.bind(mainMod .. "SHIFT + S", shell("region toggle"), { description = "Region: copy, text, translate, Lens" })
hl.bind(mainMod .. "PRINT", hl.dsp.exec_cmd("hyprpicker -a"), { description = "Color picker" })
hl.bind(mainMod .. "SHIFT + P", hl.dsp.window.tag({ tag = "noop" }), { description = "Tag window for no opacity" })
