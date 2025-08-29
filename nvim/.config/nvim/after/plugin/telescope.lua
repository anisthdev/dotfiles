local telescope = require("telescope")
local builtin = require("telescope.builtin")
local actions = require("telescope.actions")
local map = vim.keymap.set

telescope.setup({
	defaults = {
		prompt_prefix = " ",
		selection_caret = "  ",
		sorting_strategy = "ascending",
		layout_strategy = "flex",
		layout_config = {
			horizontal = {
				prompt_position = "top",
			},
		},
		file_ignore_patterns = {
			"^%.git/",
			"^%.git$",
			".DS_Store",
		},
		mappings = {
			n = {
				["<C-c"] = actions.close,
			},
			i = {
				["<C-s>"] = "select_vertical",
			},
		},
		border = true,
		theme = "ivy",
		borderchars = { " ", " ", " ", " ", " ", " ", " ", " " },
		color_devicons = true,
	},
	pickers = {
		find_files = {
			theme = "ivy",
		},
		live_grep = {
			additional_args = { "--hidden" },
			theme = "ivy",
		},
		buffers = {
			sort_mru = true,
			theme = "ivy",
		},
		oldfiles = {
			cwd_only = true,
		},
		lsp_document_symbol = {
			symbol_width = 40,
		},
	},
	fzf = {
		fuzzy = true,
		override_generic_sorter = true,
		override_file_sorter = true,
		case_mode = "smart_case",
	},

	extensions = {
		["ui-select"] = {
			layout_config = {
				width = 75,
				height = 10,
			},
		},
	},
})

vim.api.nvim_set_hl(0, "TelescopeNormal", { link = "NormalFloat" })
vim.api.nvim_set_hl(0, "TelescopeBorder", { link = "NormalFloat" })
vim.api.nvim_set_hl(0, "TelescopePromptNormal", { link = "NormalFloat" })

telescope.load_extension("fzf")
telescope.load_extension("ui-select")

map("n", "<C-p>", ":Telescope<CR>")
map("n", "<leader>fb", builtin.buffers)
map("n", "<leader>ff", builtin.find_files)
map("n", "<leader>fg", builtin.live_grep)
map("n", "<leader>f/", "<cmd>Telescope current_buffer_fuzzy_find fuzzy=false case_mode=smart_case<cr>")
map("n", "<leader>fk", "<cmd>Telescope quickfix<cr>")
map("n", "<leader>fd", "<cmd>Telescope diagnostics bufnr=0 sort_by=severity<cr>")
