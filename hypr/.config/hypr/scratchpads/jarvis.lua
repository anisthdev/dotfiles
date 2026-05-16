local mainMod = "SUPER + "

local name = "jarvis"
local window_query = "class:jarvis"
local command =
	"uwsm app -- foot -a jarvis --title=scratchpad-opencode -o 'font=SF Mono:size=12' -e env OPENCODE_CONFIG=/home/asif/.config/jarvis/opencode.json /home/asif/.opencode/bin/opencode ~"

local function toggle()
	if hl.get_window(window_query) then
		hl.dispatch(hl.dsp.workspace.toggle_special(name))
	else
		hl.exec_cmd(command)
	end
end

hl.window_rule({
	match = { class = "jarvis" },
	workspace = "special:" .. name,
	float = true,
	size = { "monitor_w*0.28", "monitor_h*0.7" },
	move = { 10, "monitor_h*0.3-10" },
})

hl.bind(mainMod .. "C", toggle, { description = "Toggle Jarvis" })
