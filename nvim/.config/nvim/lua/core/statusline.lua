-- Native statusline (replaces lualine). Layout mirrors the old lualine config:
-- [mode] [branch] buffers ............ lsp-progress diff diagnostics | flutter-device lsp | location
local M = {}

local modes = {
	n = { "NORMAL", "Normal" },
	no = { "O-PENDING", "Normal" },
	i = { "INSERT", "Insert" },
	ic = { "INSERT", "Insert" },
	v = { "VISUAL", "Visual" },
	V = { "V-LINE", "Visual" },
	["\22"] = { "V-BLOCK", "Visual" },
	s = { "SELECT", "Visual" },
	S = { "S-LINE", "Visual" },
	["\19"] = { "S-BLOCK", "Visual" },
	R = { "REPLACE", "Replace" },
	Rv = { "V-REPLACE", "Replace" },
	c = { "COMMAND", "Command" },
	t = { "TERMINAL", "Terminal" },
	nt = { "NORMAL", "Normal" },
	r = { "PROMPT", "Command" },
	["!"] = { "SHELL", "Terminal" },
}

local filetype_names = {
	TelescopePrompt = "\u{f46b} Find",
	oil = "\u{eaec} Oil",
	checkhealth = "\u{ef89} health",
}

local diag_icons = {
	{ vim.diagnostic.severity.ERROR, "\u{ea87} ", "DiagnosticError" },
	{ vim.diagnostic.severity.WARN, "\u{ea6c} ", "DiagnosticWarn" },
	{ vim.diagnostic.severity.INFO, "\u{ea74} ", "DiagnosticInfo" },
	{ vim.diagnostic.severity.HINT, "\u{f0eb} ", "DiagnosticHint" },
}

local function esc(s)
	return (s:gsub("%%", "%%%%"))
end

---------------------------------------------------------------------------
-- highlights (taken from gruvbox-material's palette, like its lualine theme)
---------------------------------------------------------------------------
local function set_highlights()
	local ok, palette = pcall(function()
		local cfg = vim.fn["gruvbox_material#get_configuration"]()
		return vim.fn["gruvbox_material#get_palette"](cfg.background, cfg.foreground, cfg.colors_override)
	end)
	if not ok then
		return
	end
	local p = function(name)
		return palette[name][1]
	end
	local bg_c, bg_b, fg, dark = p("bg_statusline1"), p("bg_statusline3"), p("fg1"), p("bg0")
	local set = vim.api.nvim_set_hl

	for group, color in pairs({
		Normal = p("grey2"),
		Insert = p("bg_green"),
		Visual = p("bg_red"),
		Replace = p("bg_yellow"),
		Command = p("blue"),
		Terminal = p("purple"),
	}) do
		set(0, "StlMode" .. group, { bg = color, fg = dark, bold = true })
	end
	set(0, "StatusLine", { bg = bg_c, fg = fg })
	set(0, "StatusLineNC", { bg = bg_c, fg = p("grey2") })
	set(0, "StlSection", { bg = bg_b, fg = fg })
	set(0, "StlBufActive", { bg = p("bg_green"), fg = dark, bold = true })
	set(0, "StlBufInactive", { bg = bg_c, fg = p("grey2") })
	set(0, "StlDiffAdd", { bg = bg_c, fg = p("green") })
	set(0, "StlDiffChange", { bg = bg_c, fg = p("blue") })
	set(0, "StlDiffDelete", { bg = bg_c, fg = p("red") })
	for _, d in ipairs(diag_icons) do
		local hl = vim.api.nvim_get_hl(0, { name = d[3], link = false })
		set(0, "Stl" .. d[3], { bg = bg_c, fg = hl.fg })
	end
end

---------------------------------------------------------------------------
-- components
---------------------------------------------------------------------------
local function mode()
	local m = modes[vim.api.nvim_get_mode().mode] or { vim.api.nvim_get_mode().mode, "Normal" }
	return ("%%#StlMode%s# \u{e62b} %s "):format(m[2], m[1])
end

local function branch()
	local head = vim.b.gitsigns_head or vim.g.gitsigns_head
	if not head or head == "" then
		return ""
	end
	return "%#StlSection# \u{f419}  " .. esc(head) .. " "
end

function _G.StatuslineBufClick(bufnr)
	if vim.api.nvim_buf_is_valid(bufnr) then
		vim.api.nvim_set_current_buf(bufnr)
	end
end

local function buffers()
	local current = vim.api.nvim_get_current_buf()
	local out = {}
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.bo[buf].buflisted then
			local name = filetype_names[vim.bo[buf].filetype]
				or vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
			if name == "" then
				name = "[No Name]"
			end
			if vim.bo[buf].modified then
				name = name .. " \u{25cf}"
			end
			local hl = buf == current and "%#StlBufActive#" or "%#StlBufInactive#"
			out[#out + 1] = ("%s%%%d@v:lua.StatuslineBufClick@ %s %%X"):format(hl, buf, esc(name))
		end
	end
	return table.concat(out) .. "%#StatusLine#"
end

-- lsp progress: spinner + server name while any client is working
local progress = {}
local spinner = { ".  ", ".. ", "...", " ..", "  .", "   " }
local frame = 0

local function lsp_progress()
	local names = {}
	for _, name in pairs(progress) do
		names[#names + 1] = name
	end
	if #names == 0 then
		return ""
	end
	return "%#StatusLine#" .. spinner[frame % #spinner + 1] .. " " .. esc(table.concat(names, ", ")) .. " "
end

local function diff()
	local d = vim.b.gitsigns_status_dict
	if not d then
		return ""
	end
	local out = {}
	for _, item in ipairs({
		{ "added", "+", "StlDiffAdd" },
		{ "changed", "~", "StlDiffChange" },
		{ "removed", "-", "StlDiffDelete" },
	}) do
		local n = d[item[1]]
		if n and n > 0 then
			out[#out + 1] = ("%%#%s#%s%d"):format(item[3], item[2], n)
		end
	end
	return #out > 0 and table.concat(out, " ") .. " " or ""
end

local function diagnostics()
	local counts = vim.diagnostic.count(0)
	local out = {}
	for _, d in ipairs(diag_icons) do
		local n = counts[d[1]]
		if n and n > 0 then
			out[#out + 1] = ("%%#Stl%s#%s%d"):format(d[3], d[2], n)
		end
	end
	return #out > 0 and table.concat(out, " ") .. " " or ""
end

local function lsp_clients()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	local first = clients[1]
	if not first then
		return ""
	end
	local text = first.name .. (#clients > 1 and (" +" .. (#clients - 1)) or "")
	return "%#StlSection# \u{f085}  " .. esc(text) .. " "
end

function M.render()
	return table.concat({
		mode(),
		branch(),
		"%#StatusLine#%<",
		buffers(),
		"%=",
		lsp_progress(),
		diff(),
		diagnostics(),
		lsp_clients(),
		modes[vim.api.nvim_get_mode().mode] and ("%%#StlMode%s#"):format(modes[vim.api.nvim_get_mode().mode][2])
			or "%#StlModeNormal#",
		" %3l:%-2v ",
	})
end

---------------------------------------------------------------------------
-- setup
---------------------------------------------------------------------------
local group = vim.api.nvim_create_augroup("user-statusline", { clear = true })
local redraw = function()
	vim.cmd.redrawstatus()
end

vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = set_highlights })
vim.api.nvim_create_autocmd({ "ModeChanged", "DiagnosticChanged", "LspAttach", "LspDetach", "BufModifiedSet" }, {
	group = group,
	callback = redraw,
})
vim.api.nvim_create_autocmd("User", {
	group = group,
	pattern = { "GitSignsUpdate", "GitSignsChanged" },
	callback = redraw,
})
vim.api.nvim_create_autocmd("LspProgress", {
	group = group,
	callback = function(ev)
		local id, value = ev.data.client_id, ev.data.params.value
		if type(value) ~= "table" then
			return
		end
		frame = frame + 1
		if value.kind == "end" then
			vim.defer_fn(function()
				progress[id] = nil
				redraw()
			end, 500)
		else
			local client = vim.lsp.get_client_by_id(id)
			progress[id] = client and client.name or ("client " .. id)
		end
		redraw()
	end,
})

set_highlights()
vim.o.laststatus = 3
vim.o.statusline = "%!v:lua.require'core.statusline'.render()"

return M
