return {
	"rachartier/tiny-code-action.nvim",
	enabled = false,
	dependencies = {
		{ "nvim-lua/plenary.nvim" },
	},
	event = "LspAttach",
	opts = {
		backend = "diffsofancy",
		picker = {
			"buffer",
			opts = {
				position = "cursor", -- Position of the picker window
				winborder = "rounded", -- Border style for picker and preview windows
			},
		},
		backend_opts = {
			delta = {
				header_lines_to_remove = 4,
				args = {
					"--line-numbers",
				},
			},
		},

		resolve_timeout = 100, -- Timeout in milliseconds to resolve code actions

		signs = {
			quickfix = { " ", { link = "DiagnosticWarning" } },
			others = { " ", { link = "DiagnosticWarning" } },
			refactor = { " ", { link = "DiagnosticInfo" } },
			["refactor.move"] = { "󰪹 ", { link = "DiagnosticInfo" } },
			["refactor.extract"] = { " ", { link = "DiagnosticError" } },
			["source.organizeImports"] = { " ", { link = "DiagnosticWarning" } },
			["source.fixAll"] = { "󰃢 ", { link = "DiagnosticError" } },
			["source"] = { "  ", { link = "DiagnosticError" } },
			["rename"] = { "󰑕 ", { link = "DiagnosticWarning" } },
			["codeAction"] = { " ", { link = "DiagnosticWarning" } },
		},
	},
}
