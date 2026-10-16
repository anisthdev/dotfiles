-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Media keys go to the active player (mpv, firefox, or mpd), see ~/.local/bin/media
local media = os.getenv("HOME") .. "/.local/bin/media "
hl.bind("XF86AudioNext", hl.dsp.exec_cmd(media .. "next"), { locked = true })
hl.bind("XF86AudioStop", hl.dsp.exec_cmd(media .. "stop"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd(media .. "toggle"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(media .. "toggle"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd(media .. "prev"), { locked = true })
