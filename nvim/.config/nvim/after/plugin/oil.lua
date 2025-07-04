require("oil").setup({
	default_file_explorer = true,
})
vim.keymap.set("n", "-", "<cmd>Oil<CR>", { desc = "open parent directory" })
