-- To add a new language server see file lsp_config.lua
return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/nvim-cmp", -- pluging to auto complete
  },
  config = function()
    require("nvim-treesitter").setup({})
    lspconfig = require("lspconfig")
    SetupLangServers(lspconfig)
  end
}
