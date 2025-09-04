return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local lualine_theme = require("ui.lualine")

		local function lsp_status()
			local clients = vim.lsp.get_clients({ bufnr = 0 })
			if #clients == 0 then
				return ""
			end

			local first_client = clients[1].name:match("^%s*(.-)%s*$")
			if #clients == 1 then
				return first_client
			else
				local extra_count = #clients - 1
				return first_client .. " +" .. extra_count
			end
		end

		local function flutter_device()
			local decorations = vim.g.flutter_tools_decorations
			if decorations and decorations.device and decorations.device.name then
				local device_name = decorations.device.name

				local name_part = device_name:match("^([^%(]*)")
				if name_part then
					name_part = name_part:gsub("%s+$", "")
				else
					name_part = device_name
				end

				if #name_part > 8 then
					return name_part:sub(1, 8)
				else
					return name_part
				end
			end
			return ""
		end

		require("lualine").setup({
			options = {
				icons_enabled = true,
				theme = lualine_theme.theme,
				section_separators = "",
				component_separators = "", -- { left = "│", right = "│" },
				disabled_filetypes = {
					statusline = {},
					winbar = {},
				},
				globalstatus = true,
				always_show_tabline = true,
				refresh = {
					statusline = 500,
					tabline = 500,
					winbar = 500,
				},
			},
			sections = {
				lualine_a = { { "mode", icon = "" } },
				lualine_b = { { "branch", icon = "" } },
				lualine_c = {
					{
						"buffers",
						show_filename_only = true,
						show_modified_status = true,
						mode = 0,
						max_length = vim.o.columns * 2 / 3,
						filetype_names = {
							TelescopePrompt = " ",
							dashboard = "Dashboard",
							oil = "Oil",
						},
						buffers_color = {
							active = { bg = lualine_theme.colors.yellow, fg = lualine_theme.colors.bg1 },
							inactive = { bg = lualine_theme.colors.bg1, fg = lualine_theme.colors.disable },
						},
						symbols = {
							alternate_file = "",
							directory = " ",
						},
					},
				},
				lualine_x = { "diff", "diagnostics" },
				lualine_y = {
					{
						"lsp_progress",
						colors = {
							percentage = lualine_theme.colors.aqua,
							title = lualine_theme.colors.aqua,
							message = lualine_theme.colors.aqua,
							spinner = lualine_theme.colors.aqua,
							lsp_client_name = lualine_theme.colors.yellow,
							use = true,
						},
						separators = {
							component = " ",
							progress = " | ",
							message = { pre = "(", post = ")" },
							percentage = { pre = "", post = "%% " },
							title = { pre = "", post = ": " },
							lsp_client_name = { pre = "[", post = "]" },
							spinner = { pre = "", post = "" },
							-- message = { commenced = "In Progress", completed = "Completed" },
						},
						display_components = { "spinner", { "title", "percentage", "message" } },
						timer = { progress_enddelay = 500, spinner = 1000, lsp_client_name_enddelay = 1000 },
						spinner_symbols = { ".  ", ".. ", "...", " ..", "  .", "   " },
					},
					{
						flutter_device,
						icon = "",
						color = { fg = lualine_theme.colors.violet, bg = lualine_theme.colors.bg2 },
					},
					-- {
					-- 	function()
					-- 		return "│"
					-- 	end, -- fake separator
					-- 	color = { fg = lualine_theme.colors.aqua, bg = lualine_theme.colors.bg2 }, -- red line on same bg
					-- 	padding = { left = 1, right = 1 },
					-- },
					{
						lsp_status,
						icon = " ",
						color = { fg = lualine_theme.colors.green, bg = lualine_theme.colors.bg2 },
					}, -- LSP status
				},
				lualine_z = { "location" },
			},
			tabline = {
				lualine_a = {
					{
						"tabs",
						mode = 2,
						tabs_color = {
							active = { fg = lualine_theme.colors.bg1, bg = lualine_theme.colors.yellow },
							inactive = { fg = lualine_theme.colors.disable, bg = lualine_theme.colors.bg1 },
						},
					},
				},
			},
			winbar = {},
			inactive_winbar = {},
			extensions = { "oil", "quickfix" },
		})

		vim.schedule(function()
			vim.opt.showtabline = 1
		end)
	end,
}
