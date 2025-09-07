local M = {}

function M.setup()
	require("lsp.diagnostics").setup()
	local capabilities = require("lsp.handlers").capabilities
	local on_attach = require("lsp.handlers").on_attach
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
		callback = function(event)
			on_attach(event)
		end,
	})
	local servers = {
		"lua_ls",
		"ts_ls",
		"pyright",
		"eslint",
		"rust_analyzer",
		"cssls",
		"tailwindcss",
		"marksman",
	}
	vim.lsp.enable("kotlin_lsp")
	for _, server in ipairs(servers) do
		local has_custom_config, server_config = pcall(require, "lsp.servers." .. server)
		if has_custom_config then
			local config = server_config.config or {}
			config.capabilities = config.capabilities or capabilities
			require("lspconfig")[server].setup(config)
		else
			-- Use default configuration
			require("lspconfig")[server].setup({
				capabilities = capabilities,
			})
		end
	end
end

return M
