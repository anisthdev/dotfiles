local function map(mode, lhs, rhs, opts)
	local options = { noremap = true, silent = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.keymap.set(mode, lhs, rhs, options)
end

-- leader and localleader setup
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- jj for normal mode
map("i", "jj", "<Esc>", { desc = "return to normal mode" })

-- window navigation
map("n", "<A-h>", "<C-w>h")
map("n", "<A-j>", "<C-w>j")
map("n", "<A-k>", "<C-w>k")
map("n", "<A-l>", "<C-w>l")

-- buffer navigation
map("n", "<S-l>", ":bnext<CR>")
map("n", "<S-h>", ":bprevious<CR>")

-- clear highlights
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- indentations
map("v", "<", "<gv")
map("v", ">", ">gv")

-- move text up down
map("x", "J", ":m '>+1<CR>gv=gv")
map("x", "K", ":m '<-2<CR>gv=gv")

-- cusor centered when jumping
map("n", "n", "nzzzv")

-- save and quit
map("n", "<leader>w", ":w<CR>", { desc = "save file" })
map("n", "<leader>q", ":q<CR>", { desc = "quit window" })
map("n", "<leader>Q", ":qa<CR>", { desc = "quit neovim" })
map("n", "<leader>bd", ":bd<CR>", { desc = "close buffer" })
-- map("n", "gf", ":lua OpenFile()<cr>", { desc = "Open or create file under cursor" })

-- toggle diagnostics
map("n", "<leader>td", function()
	local enabled = vim.diagnostic.is_enabled()
	vim.diagnostic.enable(not enabled)
	vim.notify("Diagnostics " .. (enabled and "disabled" or "enabled"), vim.log.levels.INFO)
end, { desc = "toggle diagnostics" })

-- others
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
map("n", "<leader><leader>S", ":source %<CR>", { desc = "source buffer" })
map("n", "j", "gj", { desc = "down in wrapped line" })
map("n", "k", "gk", { desc = "up in wrapped line" })
map("n", "<C-S-H>", "3<C-w>>", { desc = "Resize Left" })
map("n", "<C-S-J>", "3<C-w>-", { desc = "Resize Right" })
map("n", "<C-S-K>", "3<C-w>+", { desc = "Resize Up" })
map("n", "<C-S-L>", "3<C-w><", { desc = "Resize Down" })
