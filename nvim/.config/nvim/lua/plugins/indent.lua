return {
	"lukas-reineke/indent-blankline.nvim",
	main = "ibl",
	opts = {},
	config = function()
		require("ibl").setup({
			indent = {
				char = "┊", --"┊│",
				tab_char = "┊",
			},
			scope = {
				show_start = false,
				show_end = false,
			},
			exclude = {
				filetypes = {
					"help",
					"alpha",
					"dashboard",
					"neo-tree",
					"Trouble",
					"lazy",
					"mason",
					"notify",
					"togglerterm",
					"lazyterm",
					"fugitive",
				},
			},
		})
	end,
}
