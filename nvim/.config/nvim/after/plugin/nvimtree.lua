vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.termguicolors = true

require("nvim-tree").setup({
	sort = {
		sorter = "case_sensitive",
	},
	view = {
		width = 30,
	},
	renderer = {
		group_empty = true,
	},
	filters = {
		dotfiles = true,
	},
})

vim.keymap.set("n", "<leader>pv", function()
    local view = require("nvim-tree.view")
    if view.is_visible() then
        view.focus()
    else
        require("nvim-tree").open()
    end
end, { desc = "Focus or open file tree" })

