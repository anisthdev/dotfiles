local map = vim.keymap.set

map("n", "<leader>gs", ":Git<cr>", { desc = "Git status" })
map("n", "<leader>gc", ":Git commit<cr>", { desc = "Git commit" })
map("n", "<leader>gp", ":Git push<cr>", { desc = "Git push" })
map("n", "<leader>gP", ":Git pull --rebase<cr>", { desc = "Git pull" })
map("n", "<leader>gd", ":Gdiffsplit<cr>", { desc = "Git diff in split" })
map("n", "<leader>gl", ":Git log --oneline --graph<cr>", { desc = "Git diff in split" })
map("n", "<leader>gh", ":0Gclog<cr>", { desc = "Git history for current file" })

vim.api.nvim_create_augroup("FugitiveLeft", { clear = true })
vim.api.nvim_create_autocmd("BufWinEnter", {
	group = "FugitiveLeft",
	pattern = "fugitive://*",
	callback = function()
		vim.cmd("wincmd H")
		local total_cols = vim.o.columns
		local target_width = math.floor(total_cols / 4)
		vim.cmd("vertical resize " .. target_width)
	end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
	group = "FugitiveLeft",
	pattern = "COMMIT_EDITMSG",
	callback = function()
		vim.cmd("wincmd J")
		vim.cmd("resize 15")
	end,
})
