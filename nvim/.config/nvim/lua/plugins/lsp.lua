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
				runtime = {
					version = "LuaJIT",
					path = {
						"?.lua",
						"?/init.lua",
						vim.fn.stdpath("data") .. "lazy/?.lua",
						vim.fn.stdpath("data") .. "lazy/?/init.lua",
					},
				},
				completion = {
					callSnippet = "Replace",
					keywordSnippet = "Replace",
				},
				diagnostics = {
					globals = { "vim" },
					useLocalExclude = { "_*" },
				},
				workspace = {
					library = {
						vim.api.nvim_get_runtime_file("", true),
						[vim.fn.expand("$VIMRUNTIME/lua")] = true,
						[vim.fn.stdpath("config") .. "/lua"] = true,
					},
					maxPreload = 2000,
					preloadFileSize = 50000,
					checkThirdParty = false,
				},
				telemetry = { enable = false },
			},
		},
	},
	pyright = {
		settings = {
			pyright = {
				disableOrganizeImports = true,
			},
			python = {
				analysis = {
					autoSearchPaths = true,
					diagnosticMode = "workspace",
					useLibraryCodeForTypes = true,
					typeCheckingMode = "basic",
				},
			},
		},
	},
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
