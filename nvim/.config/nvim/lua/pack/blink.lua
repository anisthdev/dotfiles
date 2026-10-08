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
	fuzzy = { implementation = "lua" },
})
