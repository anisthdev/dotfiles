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
					vim.keymap.set(
						"n",
						"<leader>r",
						":FlutterRestart<CR>",
						{ buffer = bufnr, desc = "[R]estart Flutter" }
					)
					vim.keymap.set(
						"n",
						"<leader>h",
						":FlutterReload<CR>",
						{ buffer = bufnr, desc = "[H]ot Reload Flutter" }
					)
					vim.keymap.set(
						"n",
						"<leader>R",
						":FlutterDevices<CR>",
						{ buffer = bufnr, desc = "List Devices Flutter" }
					)
					vim.keymap.set(
						"n",
						"<leader>l",
						":FlutterLogToggle<CR>",
						{ buffer = bufnr, desc = "[L]og Toggle Flutter" }
					)
					vim.keymap.set(
						"n",
						"<leader>ft",
						":Telescope flutter commands<CR>",
						{ buffer = bufnr, desc = "[F]lutter [T]ools" }
					)
					vim.keymap.set("n", "grr", vim.lsp.buf.references, { buffer = bufnr, desc = "[G]oto [R]eferences" })
					vim.keymap.set("n", "grd", vim.lsp.buf.definition, { buffer = bufnr, desc = "[G]oto [D]efinition" })
					vim.keymap.set(
						"n",
						"gri",
						vim.lsp.buf.implementation,
						{ buffer = bufnr, desc = "[G]oto [I]mplementation" }
					)
					vim.keymap.set(
						"n",
						"gra",
						vim.lsp.buf.code_action,
						{ buffer = bufnr, desc = "[G]oto Code [A]ction" }
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
