local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
---@diagnostic disable-next-line: undefined-field
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")
--[[spec =  {
		-- LSP Saga
		{
			"nvimdev/lspsaga.nvim",
			event = "LspAttach",
		},
		-- code dimming
		{
			"folke/twilight.nvim",
		},
		-- debugger
		{
			"mfussenegger/nvim-dap",
			dependencies = {
				"jay-babu/mason-nvim-dap.nvim",
				"rcarriga/nvim-dap-ui",
				"nvim-neotest/nvim-nio",
			},
		},
	defaults = {
		lazy = false,
		version = false,
	},
	checker = { enbaled = true },
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				"matchit",
				"matchparen",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})]]
