local group = vim.api.nvim_create_augroup("user-autocmds", { clear = true })

-- briefly highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	group = group,
	callback = function()
		vim.highlight.on_yank({ higroup = "Visual", timeout = 500 })
	end,
})

-- only autocomplete in normal file buffers (not telescope prompts, oil, terminals, etc.)
vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
	group = group,
	callback = function(ev)
		if vim.bo[ev.buf].buftype ~= "" then
			vim.bo[ev.buf].autocomplete = false
		end
	end,
})
