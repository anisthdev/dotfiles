local M = {}

function M.setup()
	vim.diagnostic.config({
		severity_sort = true,
		float = { border = "rounded", source = "if_many" },
		underline = { severity = vim.diagnostic.severity.ERROR },
		signs = false,
		virtual_lines = true,
		-- virtual_text = {
		-- 	source = "if_many",
		-- 	spacing = 2,
		-- 	prefix = function(diagnostic)
		-- 		local icons = {
		-- 			[vim.diagnostic.severity.ERROR] = "  ",
		-- 			[vim.diagnostic.severity.WARN] = "  ",
		-- 			[vim.diagnostic.severity.INFO] = "  ",
		-- 			[vim.diagnostic.severity.HINT] = "  ",
		-- 		}
		-- 		return icons[diagnostic.severity]
		-- 	end,
		-- },
	})

	vim.keymap.set("n", "]d", function()
		vim.diagnostic.jump({ count = 1, float = true })
	end, { desc = "Next diagnostic" })

	vim.keymap.set("n", "[d", function()
		vim.diagnostic.jump({ count = -1, float = true })
	end, { desc = "Previous diagnostic" })

	-- Border on all lsp floating windows
	local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview

	---@diagnostic disable-next-line: duplicate-set-field
	function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
		opts = opts or {}
		opts.border = "rounded"
		return orig_util_open_floating_preview(contents, syntax, opts, ...)
	end

	vim.api.nvim_create_autocmd("CursorHold", {
		callback = function()
			local cursor_pos = vim.api.nvim_win_get_cursor(0)
			local line = cursor_pos[1] - 1
			local col = cursor_pos[2]

			local diagnostics = vim.diagnostic.get(0, {
				lnum = line,
			})

			if #diagnostics > 0 then
				-- Check if cursor is within the diagnostic range
				for _, diagnostic in ipairs(diagnostics) do
					if col >= diagnostic.col and col <= diagnostic.end_col then
						vim.diagnostic.open_float({
							scope = "cursor",
							focusable = false,
						})
						break
					end
				end
			end
		end,
	})
end

return M
