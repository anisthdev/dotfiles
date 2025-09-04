local M = {}

M.capabilities = require("blink.cmp").get_lsp_capabilities()
M.capabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}

M.on_attach = function(event)
	vim.keymap.set(
		{ "n", "x" },
		"<leader>a",
		require("tiny-code-action").code_action,
		{ desc = "LSP: [G]oto Code [A]ction" }
	)
	vim.keymap.set("n", "grr", require("telescope.builtin").lsp_references, { desc = "LSP: [G]oto [R]eferences" })
	vim.keymap.set(
		"n",
		"gri",
		require("telescope.builtin").lsp_implementations,
		{ desc = "LSP: [G]oto [I]mplementation" }
	)
	vim.keymap.set("n", "grd", require("telescope.builtin").lsp_definitions, { desc = "LSP: [G]oto [D]efinition" })
	vim.keymap.set("n", "grD", vim.lsp.buf.declaration, { desc = "LSP: [G]oto [D]eclaration" })
	vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, { desc = "LSP: Signature Help" })

	local client = vim.lsp.get_client_by_id(event.data.client_id)
	if client and client.server_capabilities.inlayHintProvider then
		vim.keymap.set("n", "<leader>Th", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
		end, { desc = "LSP: [T]oggle inlay [H]ints" })
	end
end

return M
