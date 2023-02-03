-- vim.g.mapleader = ","
vim.g.mapleader = " "

-- vim.opt.encoding="utf-8"
-- vim.opt.compatible=false
-- vim.opt.hlsearch=true
-- vim.opt.relativenumber = true
-- vim.opt.laststatus = 2
-- vim.opt.vb = true
-- vim.opt.ruler = true
-- vim.opt.spelllang="en_us"
-- vim.opt.autoindent=true
-- vim.opt.colorcolumn="120"
-- vim.opt.textwidth=120
-- vim.opt.mouse="a"
-- vim.opt.clipboard="unnamed"
-- vim.opt.scrollbind=false
-- vim.opt.wildmenu=true


-- line numbers
vim.opt.relativenumber = true -- show relative line numbers
vim.opt.number = true -- shows absolute line number on cursor line (when relative number is on)

-- tabs & indentation
vim.opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
vim.opt.shiftwidth = 2 -- 2 spaces for indent width
vim.opt.expandtab = true -- expand tab to spaces
vim.opt.autoindent = true -- copy indent from current line when starting new one

-- line wrapping
vim.opt.wrap = false -- disable line wrapping

-- search settings
vim.opt.ignorecase = true -- ignore case when searching
vim.opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

-- cursor line
vim.opt.cursorline = true -- highlight the current cursor line

-- appearance

-- turn on termguicolors for nightfly colorscheme to work
-- (have to use iterm2 or any other true color terminal)
vim.opt.termguicolors = true
vim.opt.background = "dark" -- colorschemes that can be light or dark will be made dark
vim.opt.signcolumn = "yes" -- show sign column so that text doesn't shift

-- backspace
vim.opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- clipboard
vim.opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
vim.opt.splitright = true -- split vertical window to the right
vim.opt.splitbelow = true -- split horizontal window to the bottom

vim.opt.iskeyword:append("-") -- consider string-string as whole word

local keymap = vim.keymap 

-- nvim-tree 
keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>") -- toggle file explorer