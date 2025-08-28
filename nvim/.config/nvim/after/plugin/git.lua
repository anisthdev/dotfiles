require("after.plugin.git").setup({
	signs = {
		add = { text = "│" },
		change = { text = "│" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
		untracked = { text = "┆" },
	},
	signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
	numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
	linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
	word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
	watch_gitdir = {
		follow_files = true,
		interval = 1000,
	},
	attach_to_untracked = false,
	current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
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
		-- Options for floating preview window
		border = "single",
		style = "minimal",
		relative = "cursor",
	},

	-- Keymaps
	on_attach = function(bufnr)
		local gs = require("after.plugin.git")

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
			vim.schedule(function()
				gs.next_hunk()
			end)
			return "<Ignore>"
		end, { expr = true, desc = "Go to next git hunk" })

		map("n", "[c", function()
			if vim.wo.diff then
				return "[c"
			end
			vim.schedule(function()
				gs.prev_hunk()
			end)
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
map("n", "<leader>gl", ":Git log --oneline --graph<cr>", { desc = "Git diff in split" })
map("n", "<leader>gh", ":0Gclog<cr>", { desc = "Git history for current file" })

vim.api.nvim_create_augroup("GitLayout", { clear = true })

local function open_bottom()
	vim.cmd("wincmd J")
	vim.cmd("resize 15")
end

vim.api.nvim_create_autocmd("BufWinEnter", {
	group = "GitLayout",
	callback = function(args)
		local ft = vim.bo[args.buf].filetype
		if ft == "fugitive" then
			vim.cmd("wincmd H")
			local total_cols = vim.o.columns
			local target_width = math.floor(total_cols / 4)
			vim.cmd("vertical resize " .. target_width)
		end
	end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
	group = "GitLayout",
	pattern = "COMMIT_EDITMSG",
	callback = open_bottom,
})

vim.api.nvim_create_autocmd("FileType", {
	group = "GitLayout",
	pattern = "git",
	callback = open_bottom,
})
