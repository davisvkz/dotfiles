vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.wrap = false
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.hidden = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.scrolloff = 4
vim.opt.cmdheight = 2
vim.opt.updatetime = 100
vim.opt.encoding = 'utf-8'
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.autoread = true
vim.opt.mouse = ''
vim.opt.swapfile = false
vim.opt.listchars="tab:->,space:␣"
vim.opt.list = true

-- use spaces for tabs and whatnot
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.shiftround = true
vim.opt.expandtab = false

vim.opt.smarttab = true
vim.opt.smartindent = true

-- use filetypes and for lsp
vim.cmd [[ filetype on ]]
vim.cmd [[ filetype plugin on ]]
vim.cmd [[ filetype indent on ]]
