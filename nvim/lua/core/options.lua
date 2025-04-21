-- https://neovim.io/doc/user/index.html
vim.opt.backspace = '2'
vim.opt.showcmd = true
vim.opt.laststatus = 2
vim.opt.autowrite = true
vim.opt.cursorline = true
vim.opt.autoread = true

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.shiftround = true
vim.opt.expandtab = true

vim.opt.undofile = true -- Persistent undo's across all sessions
vim.opt.backup = false -- Don't write backups. (For better performance)
vim.opt.writebackup = false -- Don't write backups.
vim.opt.autoindent = true -- Copy indent from the current line when starting a new line
vim.opt.breakindent = true -- Indent wrapped lines too.
vim.opt.copyindent = true -- Copy the structure of the existing lines' indents.
vim.opt.smartindent = true -- Non-strict cindent.
vim.opt.number = true -- Enable line numbers
vim.opt.splitbelow = true -- Split "right"
vim.opt.splitright = true -- Split "right"
vim.opt.termguicolors = true

vim.opt.spell = true
vim.opt.spelllang = { 'en_us' }

vim.cmd( [[set mouse=a]] )
vim.cmd( [[set noswapfile]] )
vim.keymap.set('n', '<leader>h', ':nohlsearch<CR>')
