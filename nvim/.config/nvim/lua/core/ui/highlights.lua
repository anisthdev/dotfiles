vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank({ higroup = "Visual", timeout = 500 })
	end,
})

local float_hl = vim.api.nvim_get_hl(0, { name = "NormalFloat" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = float_hl.bg, fg = float_hl.bg })
vim.api.nvim_set_hl(0, "BlinkCmpDocBorder", { bg = float_hl.bg, fg = float_hl.bg })
