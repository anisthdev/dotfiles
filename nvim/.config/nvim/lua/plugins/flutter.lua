return {
	"nvim-flutter/flutter-tools.nvim",
	lazy = false,
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		require("flutter-tools").setup({
			lsp = {
				settings = {
					inlayHints = true,
				},
				color = {
					enabled = true,
					background = false,
					background_color = nil,
					foreground = false,
					virtual_text = true,
					virtual_text_str = "󱓻 ",
				},
				on_attach = function(_, bufnr)
					local opts = { buffer = bufnr, desc = "" }

					vim.keymap.set(
						"n",
						"<leader>r",
						":FlutterRestart<CR>",
						vim.tbl_extend("force", opts, { desc = "Run Flutter" })
					)
					vim.keymap.set(
						"n",
						"<leader>h",
						":FlutterReload<CR>",
						vim.tbl_extend("force", opts, { desc = "Run Flutter" })
					)
					vim.keymap.set(
						"n",
						"<leader>R",
						":FlutterDevices<CR>",
						vim.tbl_extend("force", opts, { desc = "Run Flutter" })
					)
					vim.keymap.set(
						"n",
						"<leader>l",
						":FlutterLogToggle<CR>",
						vim.tbl_extend("force", opts, { desc = "Run Flutter" })
					)
					vim.keymap.set("n", "<leader>th", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
					end, vim.tbl_extend("force", opts, { desc = "Run Flutter" }))
					vim.keymap.set(
						"n",
						"<leader>ft",
						":Telescope flutter commands<CR>",
						vim.tbl_extend("force", opts, { desc = "Run Flutter" })
					)
				end,
			},
			ui = {
				border = "rounded",
				notification_style = "plugin",
			},
			decorations = {
				statusline = {
					device = true,
				},
			},
			dev_log = {
				enabled = true,
				open_cmd = "belowright 15split",
				focus_on_open = false,
			},
		})

		-- hot reload on save
		vim.api.nvim_create_autocmd("BufWritePost", {
			pattern = "*.dart",
			callback = function()
				vim.schedule(function()
					vim.cmd("FlutterReload")
				end)
			end,
		})
	end,
}
