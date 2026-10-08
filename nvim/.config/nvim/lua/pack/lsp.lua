local servers = {
	"emmylua_ls",
	"vtsls",
	"pyright",
	"eslint",
	"cssls",
	"tailwindcss",
	"kotlin_lsp",
	"jdtls",
	"jsonls",
	"copilot",
}

local set_tab_completion = function(bufnr)
	vim.keymap.set("i", "<Tab>", function()
		if not vim.lsp.inline_completion.get() then
			return "<Tab>"
		end
	end, { buffer = bufnr, expr = true, desc = "Accept the current inline completion" })
end

-- define all the keymaps and other settings on lsp attach
local function on_attach(args)
	local bufnr = args.buf
	local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

	-- color highlights
	if client:supports_method("textDocument/documentColor") then
		vim.lsp.document_color.enable(true, { bufnr = bufnr }, { style = " 󱓻 " })
	end

	-- completion menu
	if client:supports_method("textDocument/completion") and client.name ~= "copilot" then
		vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
	end

	-- inline completion
	if client:supports_method("textDocument/inlineCompletion") then
		vim.lsp.inline_completion.enable()
		set_tab_completion(bufnr)
	end

	-- go to definition
	if client:supports_method("textDocument/definition") then
		vim.keymap.set("n", "grd", vim.lsp.buf.definition, { buffer = bufnr, desc = "Go to Definition" })
	end
end

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("user-lsp-attach", { clear = true }),
	callback = on_attach,
})

-- default root_markers for all servers
vim.lsp.config("*", { root_markers = { ".git" } })

-- inlay hints: enabled globally rather than per attach, because some servers (e.g. dartls)
-- register the capability dynamically after LspAttach has already fired
vim.lsp.inlay_hint.enable(true)
vim.keymap.set("n", "<leader>th", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })

-- diagnostic configuration
vim.diagnostic.config({
	severity_sort = true,
	float = { border = "rounded", source = "if_many" },
	underline = { severity = vim.diagnostic.severity.ERROR },
	signs = false,
	virtual_text = {
		prefix = function(diagnostic)
			if diagnostic.severity == vim.diagnostic.severity.ERROR then
				return "  "
			elseif diagnostic.severity == vim.diagnostic.severity.WARN then
				return "  "
			elseif diagnostic.severity == vim.diagnostic.severity.INFO then
				return "  "
			elseif diagnostic.severity == vim.diagnostic.severity.HINT then
				return "  "
			end
			return " ➤ "
		end,
		spacing = 2,
	},
})

-- :LspClients - show all LSP clients attached to the current buffer
vim.api.nvim_create_user_command("LspClients", function()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	if #clients == 0 then
		print("No LSP clients attached")
		return
	end
	for _, c in ipairs(clients) do
		print(("%-15s id=%-3d root=%s"):format(c.name, c.id, c.root_dir or "?"))
	end
end, { desc = "List LSP clients attached to the current buffer" })

-- enable the server configurations
for _, server in ipairs(servers) do
	vim.lsp.enable(server)
end
