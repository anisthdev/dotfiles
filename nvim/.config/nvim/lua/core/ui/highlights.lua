local float_hl = vim.api.nvim_get_hl(0, { name = "NormalFloat" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = float_hl.bg, fg = float_hl.bg })
