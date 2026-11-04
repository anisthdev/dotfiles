local M = {}

-- All of it sits on the colorscheme, so it goes when that reloads, as it
-- does when 'background' changes
local function apply()
	for _, name in ipairs({ "core.ui.telescope", "core.ui.highlights", "core.ui.background" }) do
		package.loaded[name] = nil
		pcall(require, name)
	end
end

apply()
vim.api.nvim_create_autocmd("ColorScheme", { callback = apply })

-- For theme-mode: the files matugen just wrote
function M.reload()
	package.loaded["core.ui.mode"] = nil
	pcall(require, "core.ui.mode")
	apply()
end

return M
