return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
	dependencies = { "nvim-tree/nvim-web-devicons", { "arkav/lualine-lsp-progress", opts = {} } },
	config = function()
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
				theme = "gruvbox-material",
				section_separators = "",
				component_separators = "", -- { left = "│", right = "│" },
				disabled_filetypes = {
					statusline = {},
					winbar = {},
				},
				globalstatus = true,
				always_show_tabline = false,
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
						buffers_color = {
							active = "lualine_a_insert", -- Color for active buffer.
							inactive = "lualine_c_inactive", -- Color for inactive buffer.
						},
						symbols = {
							alternate_file = "",
							directory = "",
						},
						filetype_names = {
							TelescopePrompt = " Find",
							dashboard = "Dashboard",
							packer = "Packer",
							fzf = "FZF",
							alpha = "Alpha",
							oil = " Oil",
							checkhealth = " health",
						},
					},
				},
				lualine_x = {
					{
						"lsp_progress",
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
					"diff",
					"diagnostics",
					{
						function()
							return " "
						end,
						color = function()
							local status = require("sidekick.status").get()
							if status then
								return status.kind == "Error" and "DiagnosticError"
									or status.busy and "DiagnosticHint"
									or "String"
							end
						end,
						cond = function()
							local status = require("sidekick.status")
							return status.get() ~= nil
						end,
					},
				},
				lualine_y = {
					{
						flutter_device,
						icon = "",
					},
					{
						lsp_status,
						icon = " ",
					},
				},
				lualine_z = { "location" },
			},
			tabline = {},
			winbar = {},
			inactive_winbar = {},
			extensions = { "quickfix" },
		})
	end,
}
