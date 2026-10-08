vim.g.gruvbox_material_enable_italic = true
vim.g.gruvbox_material_background = "soft"
vim.g.gruvbox_material_float_style = "dim"
vim.g.gruvbox_material_diagnostic_virtual_text = "highlighted"
vim.g.gruvbox_material_diagnostic_line_highlight = 1
vim.g.gruvbox_material_menu_selection_background = "blue"

-- subtle, italic code lens (e.g. "3 usages") with no background block
vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "gruvbox-material",
	callback = function()
		local aqua = vim.api.nvim_get_hl(0, { name = "Aqua", link = false }).fg or 0x89b482
		vim.api.nvim_set_hl(0, "LspCodeLens", { fg = aqua, italic = true })
		vim.api.nvim_set_hl(0, "LspCodeLensSeparator", { fg = aqua })
	end,
})

vim.cmd.colorscheme("gruvbox-material")
