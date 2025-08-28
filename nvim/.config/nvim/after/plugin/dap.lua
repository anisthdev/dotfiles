local dap = require("dap")
local dapui = require("dapui")

require("mason-nvim-dap").setup({
	ensure_installed = {
		"python",
	},
	automatic_installation = true,
	handlers = {},
})

require("dapui").setup({
	layouts = {
		{
			elements = {
				{ id = "scopes", size = 0.25 },
				{ id = "breakpoints", size = 0.25 },
				{ id = "stacks", size = 0.25 },
				{ id = "watches", size = 0.25 },
			},
			size = 40,
			position = "left",
		},
		{
			elements = {
				{ id = "repl", size = 0.5 },
				{ id = "console", size = 0.5 },
			},
			size = 10,
			position = "bottom",
		},
	},
})

-- Auto open/close dap-ui
dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
	dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
	dapui.close()
end

vim.keymap.set("n", "<F5>", function()
	require("dap").continue()
end, { desc = "DAP: Continue" })
vim.keymap.set("n", "<F6>", function()
	require("dap").step_over()
end, { desc = "DAP: Step Over" })
vim.keymap.set("n", "<F7>", function()
	require("dap").step_into()
end, { desc = "DAP: Step Into" })
vim.keymap.set("n", "<F8>", function()
	require("dap").step_out()
end, { desc = "DAP: Step Out" })
vim.keymap.set("n", "<Leader>b", function()
	require("dap").toggle_breakpoint()
end, { desc = "DAP: Toggle Breakpoint" })
vim.keymap.set("n", "<Leader>B", function()
	require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "DAP: Set Conditional Breakpoint" })
vim.keymap.set("n", "<F9>", function()
	require("dap").terminate()
end, { desc = "DAP: Terminate" })
vim.keymap.set("n", "<Leader>Du", function()
	require("dapui").toggle()
end, { desc = "DAP: Toggle UI" })
