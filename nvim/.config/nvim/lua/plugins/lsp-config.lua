return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		{ "arkav/lualine-lsp-progress", opts = {} },
		{ "williamboman/mason.nvim", opts = {} },
		-- 	{
		-- 		"VidocqH/lsp-lens.nvim",
		-- 		config = function()
		-- 			require("lsp-lens").setup({
		-- 				enable = false,
		-- 			})
		-- 			vim.api.nvim_set_hl(0, "LspLens", { link = "LSPInlayHint" })
		-- 			-- vim.keymap.set("n", "<leader>tl", ":LspLensToggle<cr>", { desc = "Toggle Code Lens" })
		-- 		end,
		-- 	},
		-- },
		{
			"oribarilan/lensline.nvim",
			tag = "1.1.0", -- or: branch = 'release/1.x' for latest non-breaking updates
			event = "LspAttach",
			config = function()
				require("lensline").setup({
					style = {
						highlight = "LspInlayHint",
					},
				})
				vim.keymap.set("n", "<leader>Tl", require("lensline").toggle_view, { desc = "Toggle Code Lens" })
			end,
		},
	},
	config = function()
		require("lsp").setup()
	end,
}
