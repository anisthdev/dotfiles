return {
	"stevearc/oil.nvim",
	lazy = false,
	config = function()
		require("oil").setup({
			default_file_explorer = true,
			float = {
				padding = 2,
				max_width = 100,
				max_height = 20,
				win_options = {
					winblend = 0,
				},
			},
			keymaps = {
				["q"] = "actions.close",
			},
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

		vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Open Oil Window" })

		vim.api.nvim_create_autocmd("User", {
			pattern = "OilActionsPost",
			callback = function(event)
				if event.data.actions.type == "move" then
					Snacks.rename.on_rename_file(event.data.actions.src_url, event.data.actions.dest_url)
				end
			end,
		})
	end,
}
