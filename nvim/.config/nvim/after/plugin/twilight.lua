require("twilight").setup({
	vim.keymap.set("n", "<leader>t", ":Twilight<CR>", { noremap = true, silent = true, desc = "toggle code dimming" }),
})
