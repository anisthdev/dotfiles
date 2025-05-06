require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    javascript = { "prettier" },
    typescript = { "prettier" },
    python = { "black" },
    java = { "clang_format" },
  },

  format_on_save = function(bufnr)
    -- Disable for large files
    local max_size = 500 * 1024
    local file = vim.api.nvim_buf_get_name(bufnr)
    if vim.fn.getfsize(file) > max_size then
      return
    end
    return { timeout_ms = 500, lsp_fallback = true }
  end,
})

