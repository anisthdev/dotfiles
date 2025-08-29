require("Comment").setup({
	-- pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
	toggler = {
		line = "<leader>cc", -- Line-comment toggle keymap
		block = "<leader>cb",
	},
	opleader = {
		line = "<leader>c",
		block = "<leader>C",
	},
	extra = {
		above = "<leader>cO",
		below = "<leader>co",
		eol = "<leader>cA",
	},
})
