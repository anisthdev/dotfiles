vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Easier window navigation
vim.keymap.set('n', '<A-h>', '<C-w>h', { desc = "Move to left split" })
vim.keymap.set('n', '<A-j>', '<C-w>j', { desc = "Move to below split" })
vim.keymap.set('n', '<A-k>', '<C-w>k', { desc = "Move to above split" })
vim.keymap.set('n', '<A-l>', '<C-w>l', { desc = "Move to right split" })

-- Smart quit (closes window or buffer)
vim.keymap.set('n', '<leader>q', ':q<CR>', { desc = "Quit current window" })
vim.keymap.set('n', '<leader>qq', ':qa<CR>', { desc = "Quit all windows" })

-- Close current buffer without closing the window
vim.keymap.set('n', '<leader>bd', ':bd<CR>', { desc = "Close buffer" })

-- Close Fugitive or special windows like quickfix, NvimTree, etc.
vim.keymap.set('n', '<leader>c', function()
  local ft = vim.bo.filetype
  if ft == "fugitive" or ft == "git" or ft == "help" or ft == "qf" or ft == "NvimTree" then
    vim.cmd("q")
  else
    vim.cmd("bd")
  end
end, { desc = "Smart close (q or bd)" })


-- Show diagnostics in a floating window
vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, { desc = "View Diagnostics" })

-- Show documentation on hover
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "LSP Hover" })

vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)

vim.keymap.set("n", "<leader>f", function()
  require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format file" })

