-- Lean config for note-taking: options + keymaps + colorscheme only
require("core.options")
require("core.keymaps")

-- Load gruvbox-material directly from lazy's install path
vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/lazy/gruvbox-material")
vim.g.gruvbox_material_enable_italic = true
vim.g.gruvbox_material_background = "soft"
vim.g.gruvbox_material_float_style = "dim"
vim.cmd.colorscheme("gruvbox-material")
