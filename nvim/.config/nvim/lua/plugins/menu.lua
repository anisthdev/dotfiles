local lsp_menus = {

	{
		name = "Goto Definition",
		cmd = vim.lsp.buf.definition,
		rtxt = "grd",
	},

	{
		name = "Goto Declaration",
		cmd = vim.lsp.buf.declaration,
		rtxt = "grD",
	},

	{
		name = "Goto Implementation",
		cmd = vim.lsp.buf.implementation,
		rtxt = "gri",
	},

	{ name = "separator" },

	{
		name = "Show signature help",
		cmd = vim.lsp.buf.signature_help,
		rtxt = "<Ctrl+k>",
	},

	{
		name = "Show References",
		cmd = vim.lsp.buf.references,
		rtxt = "grr",
	},

	{ name = "separator" },

	{
		name = "Format Buffer",
		cmd = function()
			local ok, conform = pcall(require, "conform")

			if ok then
				conform.format({ lsp_fallback = true })
			else
				vim.lsp.buf.format()
			end
		end,
		rtxt = "<leader>f",
	},

	{
		name = "Code Actions",
		cmd = vim.lsp.buf.code_action,
		rtxt = "<leader>a",
	},
}
local menu_options = {
	{
		name = "Format Buffer",
		cmd = function()
			local ok, conform = pcall(require, "conform")

			if ok then
				conform.format({ lsp_fallback = true })
			else
				vim.lsp.buf.format()
			end
		end,
		rtxt = "<leader>F",
	},

	{
		name = "Code Actions",
		cmd = vim.lsp.buf.code_action,
		rtxt = "<leader>a",
	},

	{ name = "separator" },

	{
		name = "  Lsp Actions",
		hl = "Exblue",
		items = lsp_menus,
	},

	{ name = "separator" },

	{
		name = "Edit Config",
		cmd = function()
			vim.cmd("tabnew")
			local conf = vim.fn.stdpath("config")
			vim.cmd("tcd " .. conf .. " | e init.lua")
		end,
	},

	{
		name = "Copy Content",
		cmd = "%y+",
	},

	{
		name = "Delete Content",
		cmd = "%d",
	},

	{ name = "separator" },

	{
		name = "  Toggle terminal",
		hl = "ExRed",
		cmd = function()
			vim.cmd("ToggleTerm")
		end,
	},
}
return {
	"nvzone/menu",
	dependencies = "nvzone/volt",
	config = function()
		vim.keymap.set({ "n", "v", "i" }, "<RightMouse>", function()
			require("menu.utils").delete_old_menus()
			vim.cmd.exec('"normal! \\<RightMouse>"')
			require("menu").open(menu_options, { mouse = true })
		end, {})
	end,
}
