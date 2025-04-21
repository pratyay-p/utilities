-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1


-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

 -- Make sure to set `mapleader` before lazy so your mappings are correct
vim.g.mapleader = " "

require("core.options")
require("core.keybinds")
vim.opt.mouse="a"

require("lazy").setup({
    { import = "plugins" }
})

vim.lsp.inlay_hint.enable(true)

vim.keymap.set('n', '<C-b>', ':NvimTreeFindFileToggle<CR>', {
  noremap = true
})

vim.keymap.set('n', '<leader>th', '<Esc>:below terminal<CR>', {
  noremap = true
})

vim.keymap.set('n', '<leader>tv', '<Esc>:vertical terminal<CR>', {
  noremap = true
})

vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', {
})

-- :tnoremap <Esc> <C-\><C-n>

