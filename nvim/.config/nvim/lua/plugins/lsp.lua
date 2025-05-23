vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
	callback = function(event)
		local map = function(keys, func, desc, mode)
			mode = mode or "n"
			vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end

		map("<leader>rn", "<cmd>Lspsaga rename<CR>", "rename")
		map("<leader>ca", "<cmd>Lspsaga code_action<CR>", "goto code action", { "n", "x" })
		map("gd", "<cmd>Lspsaga peek_definition<CR>", "goto definition")
		map("K", "<cmd>Lspsaga hover_doc<CR>", "hover doc")
		map("]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", "diagnostic jump next")
		map("[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", "diagnostic jump prev")
	end,
})

local capabilities = require("blink.cmp").get_lsp_capabilities()

local servers = {
	lua_ls = {
		settings = {
			Lua = {
				completion = {
					callSnippet = "Replace",
				},
				diagnostics = {
					globals = { "vim" },
				},
			},
		},
	},
	ts_ls = {},
}

local ensure_installed = vim.tbl_keys(servers or {})
vim.list_extend(ensure_installed, { "stylua", "prettier", "eslint" })

require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

require("mason-lspconfig").setup({
	ensure_installed = {},
	automatic_installation = false,
	handlers = {
		function(server_name)
			local server = servers[server_name] or {}
			server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
			if server_name == "jdtls" then
				require("java").setup()
			end
			require("lspconfig")[server_name].setup(server)
		end,
	},
})
