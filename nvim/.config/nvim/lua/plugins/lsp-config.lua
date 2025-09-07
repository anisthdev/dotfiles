return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		{ "arkav/lualine-lsp-progress", opts = {} },
		{ "williamboman/mason.nvim", opts = {} },
	},
	config = function()
		local servers = {
			"lua_ls",
			"ts_ls",
			"pyright",
			"eslint",
			"cssls",
			"tailwindcss",
			"kotlin_lsp",
		}

		-- default lsp configuration for all servers
		vim.lsp.config("*", {
			on_attach = function(_, bufnr)
				vim.keymap.set("n", "grd", vim.lsp.buf.definition, { buffer = bufnr, desc = "Go to Definition" })
				vim.keymap.set("n", "]d", function()
					vim.diagnostic.jump({ count = 1, float = true })
				end, { buffer = bufnr, desc = "Next diagnostic" })

				vim.keymap.set("n", "[d", function()
					vim.diagnostic.jump({ count = -1, float = true })
				end, { buffer = bufnr, desc = "Previous diagnostic" })
			end,
			capabilities = require("blink.cmp").get_lsp_capabilities(),
			root_markers = { ".git" },
		})

		-- default diagnostic configuration
		vim.diagnostic.config({
			severity_sort = true,
			float = { border = "rounded", source = "if_many" },
			underline = { severity = vim.diagnostic.severity.ERROR },
			signs = false,
			virtual_lines = true,
		})

		-- enable the server configurations
		for _, server in ipairs(servers) do
			vim.lsp.enable(server)
		end
	end,
}
