return {
	"sainnhe/gruvbox-material",
	priroty = 1000,
	config = function()
		vim.cmd("colorscheme gruvbox-material")
		vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", {
			fg = "#ea6962", -- red
			bg = "#3c3836", -- dark bg
			bold = true,
		})

		vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", {
			fg = "#d8a657", -- yellow
			bg = "#3c3836",
			bold = true,
		})

		vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo", {
			fg = "#7daea3", -- aqua
			bg = "#3c3836",
		})

		vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", {
			fg = "#a9b665", -- green
			bg = "#3c3836",
			italic = true,
		})
	end,
}
