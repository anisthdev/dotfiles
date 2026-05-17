local mainMod = "SUPER + "

local name = "notes"
local window_query = "class:scratchpad-notes"
local command = "uwsm app -- foot -a scratchpad-notes --title=scratchpad-notes -e nvim /home/asif/Notes"

local function toggle()
	if hl.get_window(window_query) then
		hl.dispatch(hl.dsp.workspace.toggle_special(name))
	else
		hl.exec_cmd(command)
	end
end

hl.window_rule({
	match = { class = "scratchpad-notes" },
	workspace = "special:" .. name,
	float = true,
	size = { "monitor_w*0.25", "monitor_h*0.7" },
	move = { 10, "monitor_h*0.3-10" },
})

hl.bind(mainMod .. "N", toggle, { description = "Toggle notes scratchpad" })
