-- native folding
vim.o.foldcolumn = "1"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.opt.statuscolumn = "%=%l %C %s"

vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.fillchars:append({ fold = " ", foldopen = "\u{f107}", foldclose = "\u{f105}", foldsep = " ", foldinner = " " })

-- closed fold: first line with treesitter highlights, followed by the folded line count
function _G.user_foldtext()
	local lnum = vim.v.foldstart
	local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1] or ""
	local suffix = { ("  ⋯ %d lines "):format(vim.v.foldend - lnum + 1), "Comment" }
	local tab = string.rep(" ", vim.bo.tabstop)
	local plain = { { (line:gsub("\t", tab)), "Folded" }, suffix }

	local parser = vim.treesitter.get_parser(0, nil, { error = false })
	if not parser then
		return plain
	end
	local query = vim.treesitter.query.get(parser:lang(), "highlights")
	local trees = parser:parse({ lnum - 1, lnum })
	if not query or not trees or not trees[1] then
		return plain
	end

	-- highlight group per byte; later captures win, matching treesitter's own priority
	local hls = {}
	local root = trees[1]:root()
	for id, node in query:iter_captures(root, 0, lnum - 1, lnum) do
		local srow, scol, erow, ecol = node:range()
		scol = srow < lnum - 1 and 0 or scol
		ecol = erow > lnum - 1 and #line or ecol
		for col = scol + 1, ecol do
			hls[col] = "@" .. query.captures[id]
		end
	end

	local chunks, text, hl = {}, "", hls[1]
	for col = 1, #line do
		if hls[col] ~= hl then
			table.insert(chunks, { (text:gsub("\t", tab)), hl or "Folded" })
			text, hl = "", hls[col]
		end
		text = text .. line:sub(col, col)
	end
	table.insert(chunks, { (text:gsub("\t", tab)), hl or "Folded" })
	table.insert(chunks, suffix)
	return chunks
end
vim.o.foldtext = "v:lua.user_foldtext()"
