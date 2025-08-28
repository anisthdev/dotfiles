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

require("lazy").setup({
	spec = {
		-- colorscheme
		{
			"sainnhe/gruvbox-material",
			priroty = 1000,
		},
		{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },

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
			},
		},
		-- maninpulate surroundings
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
		{
			"tpope/vim-fugitive",
			cmd = { "Git", "G", "GBrowse" },
		},

		-- oil
		{
			"stevearc/oil.nvim",
			---@module 'oil'
			dependencies = { { "echasnovski/mini.icons", opts = {} } },
			lazy = false,
		},
		-- comment
		{ "numToStr/Comment.nvim", opts = {} },
		-- bracket pairs
		{ "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
		--indentations
		{
			"lukas-reineke/indent-blankline.nvim",
			main = "ibl",
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
		-- code dimming
		{
			"folke/twilight.nvim",
		},
		-- flutter
		{
			"nvim-flutter/flutter-tools.nvim",
			lazy = false,
			dependencies = {
				"nvim-lua/plenary.nvim",
			},
			config = true,
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
		{
			"folke/lazydev.nvim",
			ft = "lua",
			opts = {},
		},
		{
			"folke/snacks.nvim",
			opts = {
				animate = {},
				scroll = {},
				notifier = {},
				statuscolumn = {},
			},
		},
		{
			"onsails/lspkind.nvim",
		},
		{
			"catgoose/nvim-colorizer.lua",
			event = "BufReadPre",
		},
		{
			"windwp/nvim-ts-autotag",
			dependencies = "nvim-treesitter/nvim-treesitter",
			config = function()
				require("nvim-ts-autotag").setup()
			end,
		},
		{
			"anisthdev/npm-runner.nvim",
			dependencies = "m00qek/baleia.nvim",
			root = {
				"package.json",
			},
			config = function()
				require("npm-runner").setup({
					focus_on_open = false,
				})
			end,
			keys = {
				{ "<leader>nt", "<cmd>NpmRun<cr>", desc = "Run Npm runner" },
				{ "<leader>l", "<cmd>NpmRunToggle dev<cr>", desc = "Toggle npm dev log" },
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
