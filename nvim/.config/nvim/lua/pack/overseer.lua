local overseer = require("overseer")

overseer.setup({
	task_list = {
		direction = "bottom",
	},
	component_aliases = {
		-- same as overseer's default, plus show output as soon as a task starts
		default = {
			{ "open_output", on_start = "always" },
			"on_exit_set_status",
			"on_complete_notify",
			{ "on_complete_dispose", require_view = { "SUCCESS", "FAILURE" } },
		},
	},
})

-- :OS <cmd> runs any shell command as a task
vim.cmd.cnoreabbrev("OS OverseerShell")

local function restart_last()
	vim.cmd("silent! wall")
	local tasks = overseer.list_tasks({
		status = { overseer.STATUS.SUCCESS, overseer.STATUS.FAILURE, overseer.STATUS.CANCELED },
		sort = require("overseer.task_list").sort_finished_recently,
	})
	if vim.tbl_isempty(tasks) then
		vim.cmd("OverseerRun")
	else
		overseer.run_action(tasks[1], "restart")
	end
end

vim.keymap.set("n", "<leader>r", "<cmd>silent! wall | OverseerRun<CR>", { desc = "run task" })
vim.keymap.set("n", "<leader>R", restart_last, { desc = "rerun last task" })
vim.keymap.set("n", "<leader>ot", "<cmd>OverseerToggle<CR>", { desc = "toggle task list" })
