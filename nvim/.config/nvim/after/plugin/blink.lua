require("blink.cmp").setup({
	keymap = {
		preset = "super-tab",
	},

	appearance = {
		nerd_font_variant = "mono",
	},

	completion = {
		documentation = { auto_show = true, auto_show_delay_ms = 500, window = { border = "rounded" } },
		menu = {
			border = "rounded",
			draw = {
				components = {
					kind_icon = {
						text = function(ctx)
							local icon = ctx.kind_icon
							if vim.tbl_contains({ "Path" }, ctx.source_name) then
								local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
								if dev_icon then
									icon = dev_icon
								end
							else
								icon = require("lspkind").symbolic(ctx.kind, {
									mode = "symbol",
								})
							end

							return icon .. ctx.icon_gap
						end,
					},
				},
			},
		},
		trigger = { show_in_snippet = false },
		signature = { window = { border = "rounded" } },
	},

	sources = {
		default = { "lsp", "path", "snippets", "lazydev" },
		per_filetype = {
			sql = { "snippets", "dadbod", "buffer" },
		},
		providers = {
			lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
			dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
		},
	},

	snippets = { preset = "luasnip" },
	fuzzy = { implementation = "lua" },
	signature = { enabled = true },
})
