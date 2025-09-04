return {
	"akinsho/toggleterm.nvim",
	version = "*",
	config = function()
		require("toggleterm").setup({
			size = 15,
			open_mapping = [[<c-\>]],
			hide_numbers = true,
			terminal_mappings = true,
			highlights = {
				Normal = {
					link = "Normal",
				},
			},
		})
	end,
}
