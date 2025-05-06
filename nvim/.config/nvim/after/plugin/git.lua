-- Gitsigns keymaps
local gitsigns = require("gitsigns")

vim.keymap.set('n', ']c', function()
  if vim.wo.diff then return ']c' end
  vim.schedule(function() gitsigns.next_hunk() end)
  return '<Ignore>'
end, { expr = true, desc = "Next Git hunk" })

vim.keymap.set('n', '[c', function()
  if vim.wo.diff then return '[c' end
  vim.schedule(function() gitsigns.prev_hunk() end)
  return '<Ignore>'
end, { expr = true, desc = "Previous Git hunk" })

vim.keymap.set('n', '<leader>hs', gitsigns.stage_hunk, { desc = "Stage hunk" })
vim.keymap.set('n', '<leader>hr', gitsigns.reset_hunk, { desc = "Reset hunk" })
vim.keymap.set('n', '<leader>hp', gitsigns.preview_hunk, { desc = "Preview hunk" })

-- Fugitive keymaps
-- Git status 
vim.keymap.set("n", "<leader>gs", function()
  vim.cmd("vertical rightbelow G")
end, { desc = "Git status (right split)" })

-- Git commit 
vim.keymap.set("n", "<leader>gc", function()
  vim.cmd("vertical rightbelow G commit")
end, { desc = "Git commit (right split)" })

-- Git push 
vim.keymap.set("n", "<leader>gp", function()
  vim.cmd("vertical rightbelow G push")
end, { desc = "Git push (right split)" })

--Git log
vim.keymap.set("n", "<leader>gl", function()
    vim.cmd("vertical rightbelow G log")
end, { desc = "Git log (right split)" })

-- Compact blame view
vim.keymap.set('n', '<leader>gb', function()
  vim.cmd('G blame -w --date=short')
  vim.cmd([[ setlocal nonumber norelativenumber ]]) -- optional: cleaner view
end, { desc = "Git blame (compact)" })

-- Full verbose blame view
vim.keymap.set('n', '<leader>gB', ':G blame<CR>', { desc = "Git blame (full)" })


-- Diffview keymaps
vim.keymap.set("n", "<leader>gd", function()
  vim.cmd("vertical rightbelow G diff")
end, { desc = "Git diff (right split)" })

vim.keymap.set('n', '<leader>gh', ':DiffviewFileHistory %<CR>', { desc = "File history" })

