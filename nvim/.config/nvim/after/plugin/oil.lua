require("oil").setup({
	default_file_explorer = true,
	view_options = {
		show_hidden = true,
		is_hidden_file = function(name, _)
			return vim.startswith(name, ".")
		end,
		is_always_hidden = function(_, _)
			return false
		end,
		natural_order = false,
		sort = {
			{ "type", "asc" },
			{ "name", "asc" },
		},
	},
})
vim.keymap.set("n", "-", "<cmd>Oil<CR>", { desc = "open parent directory" })
