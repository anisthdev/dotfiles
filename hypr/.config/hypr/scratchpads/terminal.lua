local mainMod = "SUPER + "

local name = "terminal"
local window_query = "title:scratchpad-terminal"
local command = "uwsm app -- ghostty --title=scratchpad-terminal"

local function toggle()
	if hl.get_window(window_query) then
		hl.dispatch(hl.dsp.workspace.toggle_special(name))
	else
		hl.exec_cmd(command)
	end
end

hl.window_rule({
	match = { class = "com.mitchellh.ghostty", title = "scratchpad-terminal" },
	workspace = "special:" .. name,
	float = true,
	size = { "monitor_w*0.52", "monitor_h*0.42" },
	move = { "monitor_w*0.24", "monitor_h*0.56" },
})

hl.bind(mainMod .. "grave", toggle, { description = "Toggle terminal scratchpad" })
