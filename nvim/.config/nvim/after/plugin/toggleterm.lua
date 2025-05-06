require("toggleterm").setup({
  direction = "float",
  float_opts = {
      border = "curved",
      width = math.floor(vim.o.columns * 0.5),
      height = math.floor(vim.o.lines * 0.5),
      row = math.floor((vim.o.lines - vim.o.lines * 0.5) / 2),
      col = math.floor((vim.o.columns - vim.o.columns * 0.5) / 2),
    },
  size = 20, -- fallback size, used for other directions
  open_mapping = [[<C-\>]],
  start_in_insert = true,
  persist_size = true,
})

