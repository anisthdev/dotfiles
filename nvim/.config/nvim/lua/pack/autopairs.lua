local npairs = require("nvim-autopairs")
local Rule = require("nvim-autopairs.rule")

npairs.setup({
	check_ts = true,
	ts_config = {
		python = { "string" },
	},
})

npairs.add_rules({
	Rule(" ", " "):with_pair(function(opts)
		return vim.tbl_contains({ "()", "[]", "{}" }, opts.line:sub(opts.col - 1, opts.col))
	end),
})

npairs.add_rules({
	Rule("'''", "'''", "python"),
	Rule('"""', '"""', "python"),
})
