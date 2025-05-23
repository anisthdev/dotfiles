require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"c",
		"javascript",
		"python",
		"lua",
		"vim",
		"markdown",
	},
	sync_install = false,
	auto_install = true,
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
	indent = {
		enable = true,
	},

	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "<leader>i",
			node_incremental = "<leader>i",
			scope_incremental = "<C-s>",
			node_decremental = "<bs>",
		},
	},

	textobjects = {
		select = {
			enable = true,
			lookahead = true,
			keymaps = {
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				["ic"] = "@class.inner",
				["a="] = "@assignment.outer",
				["i="] = "@assignment.inner",
				["al"] = "@loop.outer",
				["il"] = "@loop.inner",
			},
		},
		move = {
			enable = true,
			set_jumps = true, -- whether to set jumps in the jumplist
			goto_next_start = {
				["]f"] = "@function.outer",
				["]c"] = "@class.outer",
			},
			goto_next_end = {
				["]F"] = "@function.outer",
				["]C"] = "@class.outer",
			},
			goto_previous_start = {
				["[f"] = "@function.outer",
				["[c"] = "@class.outer",
			},
			goto_previous_end = {
				["[F"] = "@function.outer",
				["[C"] = "@class.outer",
			},
		},
	},
	autotag = {
		enable = true,
	},
})
