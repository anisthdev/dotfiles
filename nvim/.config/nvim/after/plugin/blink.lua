require("lspkind").init({
	mode = "symbol_text",
	preset = "codicons",
})

require("blink.cmp").setup({
	keymap = {
		preset = "default",
	},

	appearance = {
		nerd_font_variant = "mono",
	},

	completion = {
		ghost_text = { enabled = true, show_with_menu = true },
		documentation = { auto_show = true, auto_show_delay_ms = 500, window = { border = "rounded" } },
		menu = {
			auto_show = true,
			border = "rounded",
			draw = {
				components = {
					kind_icon = {
						text = function(ctx)
							return " " .. ctx.kind_icon .. ctx.icon_gap .. " "
						end,
					},
				},
			},
		},
		trigger = { show_in_snippet = false },
	},

	sources = {
		default = { "lsp", "path", "snippets", "lazydev" },
		providers = {
			lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
			dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
		},
	},

	snippets = { preset = "luasnip" },
	fuzzy = { implementation = "lua" },
	signature = { enabled = true, window = { border = "rounded" } },
})
