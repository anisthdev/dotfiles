return {
	"saghen/blink.cmp",
	event = "VimEnter",
	version = "1.*",
	dependencies = {
		{ "L3MON4D3/LuaSnip", version = "2.*", build = "make install_jsregexp" },
		"rafamadriz/friendly-snippets",
	},
	config = function()
		require("luasnip.loaders.from_vscode").lazy_load()

		require("blink.cmp").setup({
			completion = {
				menu = { auto_show = false, border = "none" },
				ghost_text = { enabled = true, show_with_menu = false },
				documentation = { auto_show = true, auto_show_delay_ms = 1500 },
				trigger = { show_in_snippet = false },
			},
			sources = {
				default = { "lsp", "path", "snippets", "lazydev" },
				providers = { lazydev = { module = "lazydev.integrations.blink", score_offset = 100 } },
			},
			snippets = { preset = "luasnip" },
			fuzzy = { implementation = "lua" },
		})
	end,
}
