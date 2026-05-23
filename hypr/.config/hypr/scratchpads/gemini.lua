local mainMod = "SUPER + "

local name = "gemini"
local window_query = "class:chrome-gemini.google.com__-Default"
local command = 'chromium --new-window --app="https://gemini.google.com" --name="Gemini" --class="Gemini"'

local function toggle()
	if hl.get_window(window_query) then
		hl.dispatch(hl.dsp.workspace.toggle_special(name))
	else
		hl.exec_cmd(command)
	end
end

hl.window_rule({
	match = { class = "chrome-gemini.google.com__-Default" },
	workspace = "special:" .. name,
	float = true,
	size = { "monitor_w*0.28", "monitor_h*0.7" },
	move = { 10, "monitor_h*0.3-10" },
})

hl.bind(mainMod .. "A", toggle, { description = "Toggle Jarvis" })
