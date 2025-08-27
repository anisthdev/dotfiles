local map = vim.keymap.set

map("n", "<leader>gs", ":Git<cr>", { desc = "Git status" })
map("n", "<leader>gc", ":Git commit<cr>", { desc = "Git commit" })
map("n", "<leader>gp", ":Git push<cr>", { desc = "Git push" })
map("n", "<leader>gP", ":Git pull --rebase<cr>", { desc = "Git pull" })
map("n", "<leader>gd", ":Gdiffsplit<cr>", { desc = "Git diff in split" })
map("n", "<leader>gl", ":Git log --oneline --graph<cr>", { desc = "Git diff in split" })
map("n", "<leader>gh", ":0Gclog<cr>", { desc = "Git history for current file" })
