return {
	"saghen/blink.cmp",
	version = "1.*",
	event = "VeryLazy",
	dependencies = {
		{ "L3MON4D3/LuaSnip", keys = {} },
		"rafamadriz/friendly-snippets",
	},
	config = function()
		require("blink.cmp").setup({
			completion = {
				menu = {
					auto_show = true,
					border = "none",
					draw = { columns = { { "kind_icon" }, { "label" }, { "kind" }, { "source_name" } } },
				},
				ghost_text = { enabled = false, show_with_menu = false },
				documentation = { auto_show = true, auto_show_delay_ms = 1500 },
				trigger = { show_in_snippet = false },
			},
			sources = { default = { "lsp", "path", "snippets", "buffer" } },
			appearance = { use_nvim_cmp_as_default = false },
			snippets = { preset = "luasnip" },
			fuzzy = { implementation = "lua" },
		})

		require("luasnip.loaders.from_vscode").lazy_load()
	end,
}
