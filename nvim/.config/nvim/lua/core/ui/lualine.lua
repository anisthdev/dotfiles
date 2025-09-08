local M = {}

M.colors = {
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

M.theme = {
	normal = {
		a = { bg = M.colors.aqua, fg = M.colors.bg_dim, gui = "bold" },
		b = { bg = M.colors.bg1, fg = M.colors.blue },
		c = { bg = M.colors.bg1, fg = M.colors.cream },
	},
	insert = {
		a = { bg = M.colors.blue, fg = M.colors.bg_dim, gui = "bold" },
		c = { bg = M.colors.bg1, fg = M.colors.cream, gui = "bold" },
	},
	visual = {
		a = { bg = M.colors.violet, fg = M.colors.black, gui = "bold" },
		c = { bg = M.colors.bg1, fg = M.colors.cream, gui = "bold" },
	},
	command = {
		a = { bg = M.colors.red, fg = M.colors.black, gui = "bold" },
		c = { bg = M.colors.bg1, fg = M.colors.cream, gui = "bold" },
	},
	terminal = {
		a = { bg = M.colors.red, fg = M.colors.black, gui = "bold" },
		c = { bg = M.colors.bg1, fg = M.colors.cream, gui = "bold" },
	},
	replace = {
		a = { bg = M.colors.blue, fg = M.colors.black, gui = "bold" },
		c = { bg = M.colors.bg1, fg = M.colors.cream, gui = "bold" },
	},
	inactive = {
		a = { bg = M.colors.green, fg = M.colors.black, gui = "bold" },
		c = { bg = M.colors.bg_dim, fg = M.colors.cream, gui = "bold" },
	},
}

return M
