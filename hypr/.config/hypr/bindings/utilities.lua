local mainMod = "SUPER + "
local scriptDir = os.getenv("HOME") .. "/.local/bin/"
local menuDir = scriptDir .. "menus/"
local glyphMenu = "rofi -modi nerdy -show nerdy -theme $HOME/.config/rofi/nerdfont-selector.rasi"

--launching
hl.bind(mainMod .. "B", hl.dsp.exec_cmd("uwsm app -- firefox"), { description = "Browser" })
hl.bind(mainMod .. "Return", hl.dsp.exec_cmd("uwsm app -- ghostty"), { description = "Terminal" })
hl.bind(mainMod .. "SHIFT + B", hl.dsp.exec_cmd("uwsm app -- firefox --private-window"), { description = "Incognito" })
hl.bind(mainMod .. "V", hl.dsp.exec_cmd("clipse-gui"), { description = "Clipboard manager" })

--Toggle switches
hl.bind(mainMod .. "SHIFT + SPACE", hl.dsp.exec_cmd("pkill -SIGUSR1 waybar"), { description = "Toggle waybar" })
hl.bind(mainMod .. "comma", hl.dsp.exec_cmd("makoctl dismiss"), { description = "Close notification" })
hl.bind(mainMod .. "CTRL + I", hl.dsp.exec_cmd(scriptDir .. "toggle-idle"), { description = "Toggle idle" })

--menus
hl.bind(mainMod .. "SPACE", hl.dsp.exec_cmd("rofi -show drun"), { description = "App launcher" })
hl.bind(mainMod .. "Q", hl.dsp.exec_cmd(menuDir .. "control-panel-script"), { description = "Control Panel" })
hl.bind(mainMod .. "E", hl.dsp.exec_cmd(menuDir .. "entertainment"), { description = "Entertainment" })
hl.bind(mainMod .. "R", hl.dsp.exec_cmd(menuDir .. "retroarch-nes"), { description = "RetroArch NES" })
hl.bind(mainMod .. "CTRL + SPACE", hl.dsp.exec_cmd(menuDir .. "wallpaper-picker"), { description = "Wallpaper picker" })
hl.bind(mainMod .. "ESCAPE", hl.dsp.exec_cmd(menuDir .. "power-menu"), { description = "Power menu" })
hl.bind(mainMod .. "CTRL + N", hl.dsp.exec_cmd(glyphMenu), { description = "Glyph selector" })
hl.bind(mainMod .. "CTRL + V", hl.dsp.exec_cmd(menuDir .. "play-video"), { description = "Play video from URL" })
hl.bind(mainMod .. "K", hl.dsp.exec_cmd(menuDir .. "keybindings"), { description = "Keybindings" })
hl.bind("PRINT", hl.dsp.exec_cmd(menuDir .. "screenshot"), { description = "Screenshot" })
hl.bind("ALT + PRINT", hl.dsp.exec_cmd(menuDir .. "screenrecord"), { description = "Screenrecord" })

--others
hl.bind(mainMod .. "SHIFT + S", hl.dsp.exec_cmd(scriptDir .. "ocr-region"), { description = "OCR region" })
hl.bind(mainMod .. "PRINT", hl.dsp.exec_cmd("hyprpicker -a"), { description = "Color picker" })
