local lualine = require("lualine")

local colors = {
	aqua = "#89B482",
	green = "#A9B665",
	blue = "#7DAEA3",
	violet = "#D3869B",
	yellow = "#D8A657",
	red = "#EA6962",
	cream = "#DDC7A1",
	bg1 = "#3C3836",
	bg2 = "#32302F",
	bg_dim = "#252423",
	disable = "#888888",
}

local gruv_material = {
	normal = {
		a = { bg = colors.aqua, fg = colors.bg_dim, gui = "bold" },
		b = { bg = colors.bg1, fg = colors.blue },
		c = { bg = colors.bg1, fg = colors.cream },
	},
	insert = {
		a = { bg = colors.blue, fg = colors.bg_dim, gui = "bold" },
		c = { bg = colors.bg2, fg = colors.cream, gui = "bold" },
	},
	visual = {
		a = { bg = colors.violet, fg = colors.black, gui = "bold" },
		c = { bg = colors.bg2, fg = colors.cream, gui = "bold" },
	},
	command = {
		a = { bg = colors.aqua, fg = colors.black, gui = "bold" },
		c = { bg = colors.bg2, fg = colors.cream, gui = "bold" },
	},
	terminal = {
		a = { bg = colors.red, fg = colors.black, gui = "bold" },
		c = { bg = colors.bg2, fg = colors.cream, gui = "bold" },
	},
	replace = {
		a = { bg = colors.blue, fg = colors.black, gui = "bold" },
		c = { bg = colors.bg2, fg = colors.cream, gui = "bold" },
	},
	inactive = {
		a = { bg = colors.green, fg = colors.black, gui = "bold" },
		c = { bg = colors.bg_dim, fg = colors.cream, gui = "bold" },
	},
}

lualine.setup({
	options = {
		icons_enabled = true,
		theme = gruv_material,
		section_separators = "",
		component_separators = "", -- { left = "│", right = "│" },
		disabled_filetypes = {
			statusline = {},
			winbar = {},
		},
		-- ignore_focus = {},
		-- always_divide_middle = true,
		globalstatus = true,
		always_show_tabline = true,
		refresh = {
			statusline = 100,
			tabline = 100,
			winbar = 100,
		},
	},
	sections = {
		lualine_a = { { "mode", icon = "" } },
		lualine_b = { { "branch", icon = " " } },
		lualine_c = {
			{
				"buffers",
				show_filename_only = true,
				show_modified_status = true,
				mode = 0,
				max_length = vim.o.columns * 2 / 3,
				filetype_names = {
					TelescopePrompt = "Telescope",
					dashboard = "Dashboard",
					packer = "Packer",
					fzf = "FZF",
					alpha = "Alpha",
					oil = "Oil",
				},
				buffers_color = {
					active = { bg = colors.yellow, fg = colors.bg1 },
					inactive = { bg = colors.bg1, fg = colors.disable },
				},
				symbols = {
					alternate_file = "",
					directory = "",
				},
			},
		},
		lualine_x = { "diff", "diagnostics" },
		lualine_y = { "searchcount", "selectioncount", "encoding", "filetype" },
		lualine_z = { "location" },
	},
	tabline = {},
	winbar = {},
	inactive_winbar = {},
	extensions = { "oil", "quickfix" },
})
vim.opt.laststatus = 3
