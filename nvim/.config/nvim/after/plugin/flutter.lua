require("flutter-tools").setup({
	lsp = {
		color = { -- show the derived colours for dart variables
			enabled = false, -- whether or not to highlight color variables at all, only supported on flutter >= 2.10
			background = false, -- highlight the background
			background_color = nil, -- required, when background is transparent (i.e. background_color = { r = 19, g = 17, b = 24},)
			foreground = false, -- highlight the foreground
			virtual_text = true, -- show the highlight using virtual text
			virtual_text_str = "■", -- the virtual text character to highlight
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
			vim.keymap.set(
				"n",
				"<leader>ft",
				":Telescope flutter commands<CR>",
				vim.tbl_extend("force", opts, { desc = "Run Flutter" })
			)
		end,
	},
	decorations = {
		statusline = {
			device = true,
			project_config = true,
		},
	},
	dev_log = {
		enabled = true,
		open_cmd = "belowright 15split",
		focus_on_open = false,
	},
	widget_guides = {
		enabled = true,
	},
})
