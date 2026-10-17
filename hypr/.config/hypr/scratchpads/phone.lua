local mainMod = "SUPER + "

local name = "phone"
local window_query = "title:Pixel 10a"
local command = "uwsm app -- /home/asif/.local/bin/mirror-phone"

local function toggle()
	if hl.get_window(window_query) then
		hl.dispatch(hl.dsp.workspace.toggle_special(name))
	else
		hl.exec_cmd(command)
	end
end

hl.window_rule({
	match = { class = "scrcpy", title = "Pixel 10a" },
	workspace = "special:" .. name,
	float = true,
	size = { "monitor_h*0.372", "monitor_h*0.84" },
	move = { 10, "monitor_h*0.16-10" },
})

hl.bind(mainMod .. "CTRL + P", toggle, { description = "Toggle phone mirror" })
