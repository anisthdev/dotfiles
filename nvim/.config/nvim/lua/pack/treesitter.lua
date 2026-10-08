-- nvim-treesitter `main` branch: parser manager only. Highlighting/indent are wired up manually.
local ts = require("nvim-treesitter")

ts.install({ "java", "c", "javascript", "python", "lua", "vim", "markdown" })

local function start(buf, lang)
	if not pcall(vim.treesitter.start, buf, lang) then
		return false
	end
	if vim.treesitter.query.get(lang, "indents") then
		vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end
	return true
end

-- highlight + indent on FileType, installing a missing parser on demand (old `auto_install`)
vim.api.nvim_create_autocmd("FileType", {
	callback = function(ev)
		local lang = vim.treesitter.language.get_lang(ev.match)
		if not lang or start(ev.buf, lang) then
			return
		end
		if vim.tbl_contains(ts.get_available(), lang) then
			ts.install(lang):await(function()
				vim.schedule(function()
					if vim.api.nvim_buf_is_valid(ev.buf) then
						start(ev.buf, lang)
					end
				end)
			end)
		end
	end,
})

-- textobjects (main branch has no keymaps config; map them explicitly)
require("nvim-treesitter-textobjects").setup({
	select = { lookahead = true },
	move = { set_jumps = true },
})

local select = require("nvim-treesitter-textobjects.select")
for lhs, query in pairs({
	af = "@function.outer",
	["if"] = "@function.inner",
	ac = "@class.outer",
	ic = "@class.inner",
	["a="] = "@assignment.outer",
	["i="] = "@assignment.inner",
	al = "@loop.outer",
	il = "@loop.inner",
}) do
	vim.keymap.set({ "x", "o" }, lhs, function()
		select.select_textobject(query, "textobjects")
	end, { desc = "select " .. query })
end

local move = require("nvim-treesitter-textobjects.move")
for lhs, spec in pairs({
	["]f"] = { move.goto_next_start, "next function start" },
	["]F"] = { move.goto_next_end, "next function end" },
	["[f"] = { move.goto_previous_start, "previous function start" },
	["[F"] = { move.goto_previous_end, "previous function end" },
}) do
	vim.keymap.set({ "n", "x", "o" }, lhs, function()
		spec[1]("@function.outer", "textobjects")
	end, { desc = spec[2] })
end

-- incremental selection: use the built-in `an` / `in` (visual mode) instead of the removed module
