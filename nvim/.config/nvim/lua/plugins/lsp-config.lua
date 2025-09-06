return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		{ "arkav/lualine-lsp-progress", opts = {} },
		{ "williamboman/mason.nvim", opts = {} },
	},
	config = function()
		require("lsp").setup()
	end,
}
