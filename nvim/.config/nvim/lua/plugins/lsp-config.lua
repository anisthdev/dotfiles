return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
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

		-- define all the keymaps and other settings on lsp attach
		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(args)
				local bufnr = args.buf
				vim.lsp.document_color.enable(true, bufnr, { style = " 󱓻 " })
				vim.keymap.set("n", "grd", vim.lsp.buf.definition, { buffer = bufnr, desc = "Go to Definition" })
			end,
		})

		-- default capabilities and root_markers for all servers
		vim.lsp.config("*", {
			capabilities = require("blink.cmp").get_lsp_capabilities(),
			root_markers = { ".git" },
		})

		-- diagnostic configuration
		vim.diagnostic.config({
			severity_sort = true,
			float = { border = "rounded", source = "if_many" },
			underline = { severity = vim.diagnostic.severity.ERROR },
			signs = false,
			virtual_text = {
				prefix = function(diagnostic)
					if diagnostic.severity == vim.diagnostic.severity.ERROR then
						return " "
					elseif diagnostic.severity == vim.diagnostic.severity.WARN then
						return " "
					elseif diagnostic.severity == vim.diagnostic.severity.INFO then
						return " "
					elseif diagnostic.severity == vim.diagnostic.severity.HINT then
						return " "
					end
					return "➤ "
				end,
				spacing = 2,
			},
		})

		-- enable the server configurations
		for _, server in ipairs(servers) do
			vim.lsp.enable(server)
		end
	end,
}
