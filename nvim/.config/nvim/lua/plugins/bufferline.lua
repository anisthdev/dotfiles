return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = "nvim-tree/nvim-web-devicons",
	config = function()
		local bufferline = require("bufferline")
		bufferline.setup({
			options = {
				style_preset = bufferline.style_preset.default,
				numbers = "ordinal", -- Show buffer numbers (1, 2, 3…)
				indicator = {
					style = "icon",
					icon = "▎",
				},
				diagnostics = "nvim_lsp", -- Show LSP diagnostics on buffers

				-- sepaator_style = "slant", -- Nice separator style
				always_show_bufferline = true,
				show_buffer_close_icons = false,
				show_close_icon = true,
				offsets = {
					{
						filetype = "NvimTree", -- Offset bufferline for NvimTree sidebar
						text = "File Explorer",
						highlight = "Directory",
						text_align = "left",
					},
				},
			},
		})
	end,
}
