-- Plugin management via native vim.pack (nvim 0.12+).
-- Hooks must be registered before vim.pack.add() so they fire on first install.
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind
		if kind ~= "install" and kind ~= "update" then
			return
		end
		if name == "telescope-fzf-native.nvim" then
			vim.system({ "make" }, { cwd = ev.data.path }):wait()
		end
		if name == "nvim-treesitter" and kind == "update" then
			if not ev.data.active then
				vim.cmd.packadd("nvim-treesitter")
			end
			vim.cmd("TSUpdate")
		end
	end,
})

local gh = function(repo)
	return "https://github.com/" .. repo
end

vim.pack.add({
	gh("sainnhe/gruvbox-material"),
	-- batch 1: simple plugins
	{ src = gh("kylechui/nvim-surround"), version = vim.version.range("*") },
	gh("windwp/nvim-autopairs"),
	gh("windwp/nvim-ts-autotag"),
	gh("stevearc/oil.nvim"),
	gh("tpope/vim-fugitive"),
	gh("lewis6991/gitsigns.nvim"),
	gh("nvim-tree/nvim-web-devicons"),
	-- batch 2: telescope
	gh("nvim-lua/plenary.nvim"),
	gh("nvim-telescope/telescope.nvim"),
	gh("nvim-telescope/telescope-ui-select.nvim"),
	gh("nvim-telescope/telescope-fzf-native.nvim"),
	-- batch 3: treesitter (main branch)
	{ src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },
	{ src = gh("nvim-treesitter/nvim-treesitter-textobjects"), version = "main" },
	-- batch 4: lsp stack (servers/formatters come from mise, no mason)
	gh("neovim/nvim-lspconfig"),
	{ src = gh("saghen/blink.cmp"), version = vim.version.range("1.*") },
	gh("rafamadriz/friendly-snippets"),
	gh("stevearc/conform.nvim"),
	-- batch 5: the rest
	gh("nvim-flutter/flutter-tools.nvim"),
	{ src = gh("akinsho/toggleterm.nvim"), version = vim.version.range("*") },
	gh("lukas-reineke/indent-blankline.nvim"),
	gh("kevinhwang91/promise-async"),
	gh("kevinhwang91/nvim-ufo"),
	gh("folke/snacks.nvim"),
})

require("pack.colorscheme")
for _, mod in ipairs({ "snacks", "surround", "autopairs", "autotag", "oil", "git", "telescope", "treesitter", "blink", "lsp", "conform", "flutter", "toggleterm", "indent", "ufo" }) do
	require("pack." .. mod)
end

