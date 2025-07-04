vim.api.nvim_set_hl(0, "YankHighlight", { bg = "#a3c0f2", fg = "#000000" })
vim.api.nvim_create_autocmd("TextYankPost", {
    pattern = "*",
    callback = function()
        vim.highlight.on_yank({ higroup = "YankHighlight", timeout = 200 })
    end,
})
