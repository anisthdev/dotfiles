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
			config = function()
				vim.cmd([[colorscheme gruvbox-material]])
			end,
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
			config = function()
				require("nvim-surround").setup()
			end,
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
		{ -- Autoformat
			"stevearc/conform.nvim",
			event = { "BufWritePre" },
			cmd = { "ConformInfo" },
			keys = {
				{
					"<leader>f",
					function()
						require("conform").format({ async = true, lsp_format = "fallback" })
					end,
					mode = "",
					desc = "[F]ormat buffer",
				},
			},
			opts = {
				notify_on_error = false,
				format_on_save = function(bufnr)
					-- Disable "format_on_save lsp_fallback" for languages that don't
					-- have a well standardized coding style. You can add additional
					-- languages here or re-enable it for the disabled ones.
					local disable_filetypes = { c = true, cpp = true }
					if disable_filetypes[vim.bo[bufnr].filetype] then
						return nil
					else
						return {
							timeout_ms = 500,
							lsp_format = "fallback",
						}
					end
				end,
				formatters_by_ft = {
					lua = { "stylua" },
					python = { "isort", "black" },
					javascript = { "prettierd", "prettier", stop_after_first = true },
					-- You can use 'stop_after_first' to run the first available formatter from the list
				},
			},
		},

		{ -- Autocompletion
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
			--- @module 'blink.cmp'
			--- @type blink.cmp.Config
			opts = {
				keymap = {
					preset = "default",
				},

				appearance = {
					nerd_font_variant = "mono",
				},

				completion = {
					documentation = { auto_show = false, auto_show_delay_ms = 500 },
				},

				sources = {
					default = { "lsp", "path", "snippets", "lazydev" },
					providers = {
						lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
					},
				},

				snippets = { preset = "luasnip" },
				fuzzy = { implementation = "lua" },
				signature = { enabled = true },
			},
		},
		{
			"nvimdev/lspsaga.nvim",
			event = "LspAttach",
			config = function()
				require("lspsaga").setup({})
			end,
		},
		{
			"stevearc/oil.nvim",
			---@module 'oil'
			---@type oil.SetupOpts
			opts = {},
			-- Optional dependencies
			dependencies = { { "echasnovski/mini.icons", opts = {} } },
			lazy = false,
			config = function()
				require("oil").setup({
					default_file_explorer = true,
				})
				vim.keymap.set("n", "-", "<cmd>Oil<CR>", { desc = "open parent directory" })
			end,
		},
		{ "numToStr/Comment.nvim", opts = {} },
		{ "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
		{ "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
		{
			"karb94/neoscroll.nvim",
			event = "VeryLazy",
			config = function()
				require("neoscroll").setup()
			end,
		},
		{
			"sphamba/smear-cursor.nvim",
			event = "VeryLazy",
			opts = {
				smear_between_neighbour_lines = true,
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
