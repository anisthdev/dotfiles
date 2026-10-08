local float_hl = vim.api.nvim_get_hl(0, { name = "NormalFloat" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = float_hl.bg, fg = float_hl.bg })

-- closed folds: gruvbox-material's bg_dim, subtler than the theme default (which matches CursorLine)
local folded_hl = vim.api.nvim_get_hl(0, { name = "Folded", link = false })
vim.api.nvim_set_hl(0, "Folded", { fg = folded_hl.fg, ctermfg = folded_hl.ctermfg, bg = "#252423" })

-- diagnostics: straight underlines instead of the theme's undercurl, keeping each severity's color
for _, severity in ipairs({ "Error", "Warn", "Info", "Hint", "Ok" }) do
	local name = "DiagnosticUnderline" .. severity
	local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
	vim.api.nvim_set_hl(0, name, { sp = hl.sp, underline = true, cterm = { underline = true } })
end
