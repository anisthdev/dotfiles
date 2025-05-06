local custom_servers = require("config.lsp_servers")

require('mason').setup({})
require('mason-lspconfig').setup({
	ensure_installed = {'lua_ls', 'rust_analyzer'},
    automatic_installation = true,
	handlers = vim.tbl_extend("force", {
        function(server_name)
            require("lspconfig")[server_name].setup({})
        end
    }, custom_servers)
})
