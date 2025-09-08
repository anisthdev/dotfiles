return {
	"catgoose/nvim-colorizer.lua",
	enabled = false,
	event = "BufReadPre",
	config = function()
		require("colorizer").setup({
			filetypes = {
				"css",
				"javascript",
				"html",
				"javascriptreact",
				"typescript",
				"typescriptreact",
				"conf",
				"scss",
				"lua",
			},
			user_default_options = {
				names = false,
				mode = "virtualtext",
				virtualtext = "󱓻 ",
				virtualtext_inline = true,
				virtualtext_mode = "foreground",
				tailwind = "lsp",
			},
		})
	end,
}
