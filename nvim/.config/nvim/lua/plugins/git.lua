return {
	"tpope/vim-fugitive",
	dependencies = {
		{ "lewis6991/gitsigns.nvim", event = "VeryLazy" },
	},
	config = function()
		require("gitsigns").setup({
			signs = {
				add = { text = "│" },
				change = { text = "│" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "┆" },
			},
			signcolumn = true,
			numhl = false,
			linehl = false,
			word_diff = false,
			watch_gitdir = {
				follow_files = true,
				interval = 1000,
			},
			attach_to_untracked = false,
			current_line_blame = false,
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
				delay = 2000,
				ignore_whitespace = false,
			},
			current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
			sign_priority = 6,
			update_debounce = 100,
			status_formatter = nil, -- Use default
			max_file_length = 40000, -- Disable if file is longer than this (in bytes)
			preview_config = {
				border = "rounded",
				style = "minimal",
				relative = "cursor",
			},

			-- Keymaps
			on_attach = function(bufnr)
				local gs = require("gitsigns")

				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end

				-- Navigation
				map("n", "]c", function()
					if vim.wo.diff then
						return "]c"
					end
					vim.schedule(gs.next_hunk)
					return "<Ignore>"
				end, { expr = true, desc = "Go to next git hunk" })
				map("n", "[c", function()
					if vim.wo.diff then
						return "[c"
					end
					vim.schedule(gs.prev_hunk)
					return "<Ignore>"
				end, { expr = true, desc = "Go to previous git hunk" })

				-- Actions
				map("n", "<leader>gs", gs.stage_hunk, { desc = "Stage git hunk" })
				map("n", "<leader>gr", gs.reset_hunk, { desc = "Reset git hunk" })
				map("n", "<leader>gS", gs.stage_buffer, { desc = "Stage entire buffer" })
				map("n", "<leader>gu", gs.undo_stage_hunk, { desc = "Undo last staged hunk" })
				map("n", "<leader>gR", gs.reset_buffer, { desc = "Reset entire buffer" })
				map("n", "<leader>gp", gs.preview_hunk, { desc = "Preview git hunk" })
				map("n", "<leader>gb", function()
					gs.blame_line({ full = true })
				end, { desc = "Git blame line" })
				map("n", "<leader>gtb", gs.toggle_current_line_blame, { desc = "Toggle line blame" })
				map("n", "<leader>gd", gs.diffthis, { desc = "Diff against index" })
				map("n", "<leader>gD", function()
					gs.diffthis("~1")
				end, { desc = "Diff against last commit" })

				-- Text object
				map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select git hunk" })
			end,
		})

		local map = vim.keymap.set

		map("n", "<leader>gg", ":Git<cr>", { desc = "Git status" })
		map("n", "<leader>gc", ":Git commit<cr>", { desc = "Git commit" })
		map("n", "<leader>gP", ":Git push<cr>", { desc = "Git push" })
		map("n", "<leader>gl", ":Git log --oneline --graph<cr>", { desc = "Git log graph" })
		map("n", "<leader>gh", ":0Gclog<cr>", { desc = "Git history for current file" })
	end,
}
