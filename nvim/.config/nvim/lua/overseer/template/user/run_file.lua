-- Run the current file on its own, picked by filetype.
local runners = {
	java = { "java" },
	python = { "python3" },
	javascript = { "node" },
	typescript = vim.fn.executable("deno") == 1 and { "deno", "run", "-A" } or { "node", "--experimental-strip-types" },
	go = { "go", "run" },
	lua = { "lua" },
	sh = { "bash" },
	bash = { "bash" },
	fish = { "fish" },
}

---@type overseer.TemplateFileDefinition
return {
	name = "run this file",
	desc = "Run the current buffer with its interpreter",
	condition = {
		filetype = vim.tbl_keys(runners),
	},
	builder = function()
		local file = vim.api.nvim_buf_get_name(0)
		local cmd = vim.list_extend(vim.deepcopy(runners[vim.bo.filetype]), { file })
		return {
			name = vim.fs.basename(file),
			cmd = cmd,
			cwd = vim.fs.dirname(file),
		}
	end,
}
