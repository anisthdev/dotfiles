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
hl.bind(mainMod .. "T", hl.dsp.exec_cmd("uwsm app -- ghostty --title=tremc -e tremc"), { description = "Tremc" })
hl.bind(mainMod .. "M", hl.dsp.exec_cmd("uwsm app -- mpv --player-operation-mode=pseudo-gui"), { description = "mpv" })
hl.bind(mainMod .. "SHIFT + B", hl.dsp.exec_cmd("uwsm app -- firefox --private-window"), { description = "Incognito" })
hl.bind(mainMod .. "V", shell("clipboard toggle"), { description = "Clipboard manager" })

--Toggle switches
hl.bind(mainMod .. "SHIFT + SPACE", shell("bar toggle"), { description = "Toggle bar" })
hl.bind(mainMod .. "comma", shell("notifications dismiss"), { description = "Close notification" })
hl.bind(mainMod .. "CTRL + I", shell("keepawake toggle"), { description = "Keep awake" })

--menus
hl.bind(mainMod .. "SPACE", shell("launcher toggle"), { description = "App launcher" })
hl.bind(mainMod .. "Q", shell("controlpanel toggle"), { description = "Control Panel" })
hl.bind(mainMod .. "E", shell("entertainment toggle"), { description = "Entertainment" })
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
