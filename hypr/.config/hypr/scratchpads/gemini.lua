local mainMod = "SUPER + "

local name = "gemini"
local window_query = "class:" .. name
local command = "firefox -P " .. name .. " --new-window https://gemini.google.com --name " .. name

local function toggle()
	if hl.get_window(window_query) then
		hl.dispatch(hl.dsp.workspace.toggle_special(name))
	else
		hl.exec_cmd(command)
	end
end

hl.window_rule({
	match = { class = name },
	workspace = "special:" .. name,
	float = true,
	size = { "monitor_w*0.28", "monitor_h*0.7" },
	move = { 10, "monitor_h*0.3-10" },
})

hl.bind(mainMod .. "A", toggle, { description = "Toggle Gemini" })
