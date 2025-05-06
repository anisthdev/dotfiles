vim.diagnostic.config({
  virtual_text = true,         -- show inline warnings/errors
  signs = true,                -- show icons in gutter
  underline = true,            -- underline the error text
  update_in_insert = false,    -- don't show while typing
  severity_sort = true,        -- sort by severity
  float = {
    border = "rounded",
    source = "always",         -- shows source like [lua_ls]
    header = "",
    prefix = "",
  },
})

