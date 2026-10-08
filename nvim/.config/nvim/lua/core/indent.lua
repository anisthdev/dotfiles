-- indent guides via 'listchars' (replaces indent-blankline): a "│" at every shiftwidth step of leading
-- whitespace, drawn with the Whitespace highlight. Only shown in normal file buffers.
local exclude = { help = true, fugitive = true, git = true, gitcommit = true }

local function update()
	local buf = vim.api.nvim_get_current_buf()
	local lcs = vim.opt_global.listchars:get()
	if vim.bo[buf].buftype == "" and not exclude[vim.bo[buf].filetype] then
		lcs.leadmultispace = "│" .. string.rep(" ", math.max(vim.fn.shiftwidth() - 1, 0))
		lcs.leadtab = "│ "
	end
	vim.opt_local.listchars = lcs
end

local group = vim.api.nvim_create_augroup("user-indent", { clear = true })
vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType" }, { group = group, callback = update })
vim.api.nvim_create_autocmd("OptionSet", {
	group = group,
	pattern = { "shiftwidth", "tabstop" },
	callback = update,
})
