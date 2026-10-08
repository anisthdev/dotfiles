-- ui2 (experimental, nvim 0.12): new message/cmdline UI. No "Press ENTER", highlighted cmdline,
-- and messages (incl. vim.notify) shown in a corner window that fades out instead of the cmdline.
require("vim._core.ui2").enable({ msg = { targets = "msg" } })

-- appearance
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.termguicolors = true
vim.opt.cmdheight = 0
vim.opt.pumheight = 10
vim.opt.wrap = false
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.o.updatetime = 1000
vim.opt.winborder = "rounded"

-- editing
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.splitright = true
vim.o.splitbelow = true

-- completion
vim.o.autocomplete = true
vim.opt.complete:prepend("o")
vim.o.completeopt = "menuone,noselect,popup"

-- cmdline completion: popup menu as you type (triggered by wildtrigger() in core/autocmds.lua)
vim.o.wildmode = "noselect:lastused,full"
vim.o.wildoptions = "pum,fuzzy"

--folding and status column
vim.o.foldcolumn = "1"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.statuscolumn = "%=%l %C %s"
vim.opt.fillchars:append({
	fold = " ",
	foldopen = "\u{f107}",
	foldclose = "\u{f105}",
	foldsep = " ",
	foldinner = " ",
})
vim.o.foldtext = "getline(v:foldstart) .. ' ...'"
