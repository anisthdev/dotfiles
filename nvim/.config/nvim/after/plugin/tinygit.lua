require("tinygit").setup({
	vim.keymap.set("n", "<leader>ga", function()
		require("tinygit").interactiveStaging()
	end, { desc = "git add" }),
	vim.keymap.set("n", "<leader>gc", function()
		require("tinygit").smartCommit()
	end, { desc = "git commit" }),
	vim.keymap.set("n", "<leader>gp", function()
		require("tinygit").push()
	end, { desc = "git push" }),
})
