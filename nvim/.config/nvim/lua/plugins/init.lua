local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
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

require("lazy").setup({
	spec = {
		-- colorscheme
		{
			"sainnhe/gruvbox-material",
			priroty = 1000,
		},
		-- lualine
		{
			"nvim-lualine/lualine.nvim",
			dependencies = { "nvim-tree/nvim-web-devicons" },
		},
		-- telescope
		{
			"nvim-telescope/telescope.nvim",
			dependencies = {
				"nvim-lua/plenary.nvim",
				"nvim-telescope/telescope-ui-select.nvim",
				{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			},
		},
		-- treesitter
		{
			"nvim-treesitter/nvim-treesitter",
			build = ":TSUpdate",
			dependencies = {
				"nvim-treesitter/nvim-treesitter-textobjects",
				"windwp/nvim-ts-autotag",
			},
		},
		{
			"kylechui/nvim-surround",
			version = "*",
			event = "VeryLazy",
		},
		-- LSP
		{
			"neovim/nvim-lspconfig",
			dependencies = {
				{ "mason-org/mason.nvim", opts = {} },
				"mason-org/mason-lspconfig.nvim",
				"WhoIsSethDaniel/mason-tool-installer.nvim",
				{ "j-hui/fidget.nvim", opts = {} },
				"saghen/blink.cmp",
			},
		},
		-- Autoformat
		{
			"stevearc/conform.nvim",
			event = { "BufWritePre" },
			cmd = { "ConformInfo" },
		},
		-- Autocompletion
		{
			"saghen/blink.cmp",
			event = "VimEnter",
			version = "1.*",
			dependencies = {
				-- Snippet Engine
				{
					"L3MON4D3/LuaSnip",
					version = "2.*",
					build = (function()
						if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
							return
						end
						return "make install_jsregexp"
					end)(),
					dependencies = {
						{
							"rafamadriz/friendly-snippets",
							config = function()
								require("luasnip.loaders.from_vscode").lazy_load()
							end,
						},
					},
					opts = {},
				},
				"folke/lazydev.nvim",
			},
		},
		-- LSP Saga
		{
			"nvimdev/lspsaga.nvim",
			event = "LspAttach",
		},
		-- oil
		{
			"stevearc/oil.nvim",
			---@module 'oil'
			---@type oil.SetupOpts
			opts = {},
			-- Optional dependencies
			dependencies = { { "echasnovski/mini.icons", opts = {} } },
			lazy = false,
		},
		-- comment
		{ "numToStr/Comment.nvim", opts = {} },
		-- bracket pairs
		{ "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
		-- indentation lines
		{ "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
		-- smooth scrolling
		{
			"karb94/neoscroll.nvim",
			event = "VeryLazy",
		},
		-- fuzzy cursor
		{
			"sphamba/smear-cursor.nvim",
			event = "VeryLazy",
			opts = {
				smear_between_neighbour_lines = true,
			},
		},
		-- code folding
		{
			"kevinhwang91/nvim-ufo",
			dependencies = "kevinhwang91/promise-async",
			event = "VeryLazy",
		},
		-- git signs
		{
			"lewis6991/gitsigns.nvim",
			event = "VeryLazy",
		},
		-- dadbod for sql queries
		{
			"kristijanhusak/vim-dadbod-ui",
			dependencies = {
				{ "tpope/vim-dadbod" },
				{ "kristijanhusak/vim-dadbod-completion" },
			},
			ft = { "sql", "plsql", "mysql" },
			init = function()
				vim.g.db_ui_save_location = "~/.config/nvim/db_ui"
				vim.g.db_ui_use_nerd_fonts = 1 -- Use Nerd Font icons
				vim.g.db_ui_show_help = 0 -- Hide the help menu by default
				vim.g.db_ui_win_position = "left" -- Open the UI on the left
				vim.g.db_ui_winwidth = 30 -- Set the UI window width
			end,
		},
		-- neogit
		{
			"NeogitOrg/neogit",
			dependencies = {
				"nvim-lua/plenary.nvim",
				"sindrets/diffview.nvim",
				"nvim-telescope/telescope.nvim",
			},
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
})

require("plugins.lsp")
