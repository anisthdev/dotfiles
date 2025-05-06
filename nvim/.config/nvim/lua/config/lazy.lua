-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },

			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end

vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)

require("lazy").setup({
	spec = {

		{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
		{
			"ellisonleao/gruvbox.nvim",
			config = function()
				require("gruvbox").setup({ contrast = "soft" })
				vim.cmd("colorscheme gruvbox")
			end,
		},
		{ "nvim-telescope/telescope.nvim", tag = "0.1.8", dependencies = { "nvim-lua/plenary.nvim" } },
		{ "neovim/nvim-lspconfig" },
		{ "hrsh7th/nvim-cmp" },
		{ "hrsh7th/cmp-nvim-lsp" },
		{ "williamboman/mason.nvim" },
		{ "williamboman/mason-lspconfig" },
		{ "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
		{ "nvim-tree/nvim-tree.lua", version = "*", lazy = false, dependencies = { "nvim-tree/nvim-web-devicons" } },
		{ "tpope/vim-fugitive", cmd = { "G", "Git", "Gdiffsplit", "Gread", "Gwrite", "Glog", "Gedit" } },
		{
			"lewis6991/gitsigns.nvim",
			event = { "BufReadPre", "BufNewFile" },
			config = function()
				require("gitsigns").setup()
			end,
		},
		{
			"sindrets/diffview.nvim",
			cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
			dependencies = { "nvim-lua/plenary.nvim" },
		},
		{ "rhysd/committia.vim", ft = "gitcommit" },
		{ "akinsho/toggleterm.nvim", version = "*" },
		{ "mfussenegger/nvim-jdtls", ft = { "java" } },
		{
			"stevearc/conform.nvim",
			opts = {},
		},

		{
			"mfussenegger/nvim-lint",
			config = function()
				require("lint").linters_by_ft = {
					javascript = { "eslint_d" },
					typescript = { "eslint_d" },
					lua = { "luacheck" },
					python = { "flake8" },
				}

				vim.api.nvim_create_autocmd({ "BufWritePost" }, {
					callback = function()
						require("lint").try_lint()
					end,
				})
			end,
		},

		{
			"jay-babu/mason-null-ls.nvim",
			dependencies = { "williamboman/mason.nvim", "nvimtools/none-ls.nvim" },
			config = function()
				require("mason-null-ls").setup({
					ensure_installed = {
						"prettier",
						"eslint_d",
						"black",
						"flake8",
						"stylua",
						"clang_format",
					},
					automatic_installation = true,
				})
			end,
		},
	},

	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	install = { colorscheme = { "habamax" } },
	-- automatically check for plugin updates
	checker = { enabled = true },
})
