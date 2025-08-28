vim.diagnostic.config({
	severity_sort = true,
	float = { border = "rounded", source = "if_many" },
	underline = { severity = vim.diagnostic.severity.ERROR },
	signs = false,
	virtual_text = {
		source = "if_many",
		spacing = 2,
	},
})

local P = {
	bg = "#282828",
	bg_soft = "#1d2021",
	fg = "#ebdbb2",
	red = "#fb4934",
	yellow = "#fabd2f",
	blue = "#83a598",
	aqua = "#8ec07c",
}

-- Tiny helpers to blend a soft background from a foreground color
local function hex_to_rgb(hex)
	hex = hex:gsub("#", "")
	return { r = tonumber(hex:sub(1, 2), 16), g = tonumber(hex:sub(3, 4), 16), b = tonumber(hex:sub(5, 6), 16) }
end
local function rgb_to_hex(rgb)
	return string.format("#%02x%02x%02x", math.floor(rgb.r + 0.5), math.floor(rgb.g + 0.5), math.floor(rgb.b + 0.5))
end
-- alpha ∈ [0,1]: amount of fg laid over bg (smaller = subtler)
local function blend(fg_hex, bg_hex, alpha)
	local fg, bg = hex_to_rgb(fg_hex), hex_to_rgb(bg_hex)
	local r = (alpha * fg.r) + ((1 - alpha) * bg.r)
	local g = (alpha * fg.g) + ((1 - alpha) * bg.g)
	local b = (alpha * fg.b) + ((1 - alpha) * bg.b)
	return rgb_to_hex({ r = r, g = g, b = b })
end

-- Soft tint for virtual text background; tweak to taste (0.06–0.12 works well)
local VT_ALPHA = is_dark and 0.08 or 0.10

-- Convenience constructor
local function vt(fg)
	return {
		fg = fg,
		bg = blend(fg, P.bg, VT_ALPHA),
		italic = true,
		nocombine = true,
	}
end

-- Underline styles use "sp" color for undercurl
local function ul(sp)
	return { undercurl = true, sp = sp }
end

-- Sign column (no background, just colored glyphs)
local function sign(fg)
	return { fg = fg, bg = "NONE" }
end

-- Apply highlights
local set = vim.api.nvim_set_hl
local ns = 0

-- VirtualText
set(ns, "DiagnosticVirtualTextError", vt(P.red))
set(ns, "DiagnosticVirtualTextWarn", vt(P.yellow))
set(ns, "DiagnosticVirtualTextInfo", vt(P.blue))
set(ns, "DiagnosticVirtualTextHint", vt(P.aqua))

-- Signs
set(ns, "DiagnosticSignError", sign(P.red))
set(ns, "DiagnosticSignWarn", sign(P.yellow))
set(ns, "DiagnosticSignInfo", sign(P.blue))
set(ns, "DiagnosticSignHint", sign(P.aqua))

-- Underlines (undercurl with colored sp)
set(ns, "DiagnosticUnderlineError", ul(P.red))
set(ns, "DiagnosticUnderlineWarn", ul(P.yellow))
set(ns, "DiagnosticUnderlineInfo", ul(P.blue))
set(ns, "DiagnosticUnderlineHint", ul(P.aqua))

-- Optional: floating windows (hover/signature help) to match Gruvbox
set(ns, "DiagnosticFloatingError", { fg = P.red })
set(ns, "DiagnosticFloatingWarn", { fg = P.yellow })
set(ns, "DiagnosticFloatingInfo", { fg = P.blue })
set(ns, "DiagnosticFloatingHint", { fg = P.aqua })

-- Keep the diagnostic text readable in virtual lines and floats
-- set(ns, "NormalFloat", { bg = P.bg_soft })
-- set(ns, "FloatBorder", { fg = P.bg_soft, bg = P.bg_soft })
