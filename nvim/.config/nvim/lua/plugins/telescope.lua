return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope-ui-select.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	},
	config = function()
		local telescope = require("telescope")
		local builtin = require("telescope.builtin")
		local actions = require("telescope.actions")
		local themes = require("telescope.themes")
		local map = vim.keymap.set

		for k, v in pairs(builtin) do
			if type(v) == "function" then
				builtin[k] = function(opts)
					opts = opts or {}
					return v(themes.get_ivy(vim.tbl_extend("force", {
						layout_config = {
							height = 20, -- absolute number of lines
						},
						border = false, -- disable border highlight
						borderchars = {
							prompt = { " ", " ", " ", " ", " ", " ", " ", " " },
							results = { " ", " ", " ", " ", " ", " ", " ", " " },
							preview = { " ", " ", " ", " ", " ", " ", " ", " " },
						},
					}, opts)))
				end
			end
		end

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
				theme = "ivy",
				border = false,
				borderchars = {
					prompt = { " ", " ", " ", " ", " ", " ", " ", " " },
					results = { " ", " ", " ", " ", " ", " ", " ", " " },
					preview = { " ", " ", " ", " ", " ", " ", " ", " " },
				},
				color_devicons = true,
			},
			pickers = {
				live_grep = {
					additional_args = { "--hidden" },
				},
				buffers = {
					sort_mru = true,
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
					themes.get_dropdown(),
				},
			},
		})

		pcall(telescope.load_extension("fzf"))
		pcall(telescope.load_extension("ui-select"))

		map("n", "<C-p>", ":Telescope<CR>")
		map("n", "<leader>fb", builtin.buffers)
		map("n", "<leader>ff", builtin.find_files)
		map("n", "<leader>fg", builtin.live_grep)
		map("n", "<leader>f/", "<cmd>Telescope current_buffer_fuzzy_find fuzzy=false case_mode=smart_case<cr>")
		map("n", "<leader>fk", "<cmd>Telescope quickfix<cr>")
		map("n", "<leader>fd", "<cmd>Telescope diagnostics bufnr=0 sort_by=severity<cr>")
	end,
}
