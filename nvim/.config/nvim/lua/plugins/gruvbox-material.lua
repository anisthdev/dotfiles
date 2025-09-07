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
			italic = true,
		})
		vim.api.nvim_set_hl(0, "DiagnosticVirtualLinesError", {
			fg = "#ea6962", -- red
			bold = true,
		})

		vim.api.nvim_set_hl(0, "DiagnosticVirtualLinesWarn", {
			fg = "#d8a657", -- yellow
			bold = true,
		})

		vim.api.nvim_set_hl(0, "DiagnosticVirtualLinesInfo", {
			fg = "#7daea3", -- aqua
		})

		vim.api.nvim_set_hl(0, "DiagnosticVirtualLinesHint", {
			fg = "#a9b665", -- green
			italic = true,
		})
	end,
}
