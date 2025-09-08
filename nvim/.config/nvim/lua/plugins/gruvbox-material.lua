return {
	"sainnhe/gruvbox-material",
	priroty = 1000,
	config = function()
		vim.g.gruvbox_material_enable_italic = true
		vim.g.gruvbox_material_background = "soft"
		vim.g.gruvbox_material_float_style = "dim"
		vim.g.gruvbox_material_diagnostic_virtual_text = "highlighted"
		vim.g.gruvbox_material_diagnostic_line_highlight = 1
		vim.g.gruvbox_material_menu_selection_background = "blue"
		vim.cmd.colorscheme("gruvbox-material")
	end,
}
