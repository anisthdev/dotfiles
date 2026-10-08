-- neovide (GUI) only: font and line height. The terminal (ghostty) uses its own font config.
if not vim.g.neovide then
	return
end

vim.o.guifont = "JetBrains Mono:h14"
vim.o.linespace = 12 -- extra pixels between lines
vim.g.neovide_floating_corner_radius = 0.4 -- rounded floating windows (0.0 square to 1.0 fully round)
