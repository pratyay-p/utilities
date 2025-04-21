local lua_lsp_settings = {
  Lua = {
    runtime = {
      -- Tell the language server which version of Lua you're using
      -- (most likely LuaJIT in the case of Neovim)
      version = 'LuaJIT',
    },
    diagnostics = {
      -- Get the language server to recognize the `vim` global
      globals = {
        'vim',
        'require'
      },
    },
    workspace = {
      -- Make the server aware of Neovim runtime files
      library = vim.api.nvim_get_runtime_file("", true),
    },
    -- Do not send telemetry data containing a randomized but unique identifier
    telemetry = {
      enable = false,
    },
  },
}

local function get_lang_server_details()
  -- install an LSP using brew and list it here
  return {
    -- lsp with specific config
    lua_ls = { settings = lua_lsp_settings },
    clangd = { on_attach = SetupClangExtn },
    -- lsp with generic config (includes auto-complete ability)
    pyright = {},
  }
end

-- SetupLangServers is called in lspconfig.config()
function SetupLangServers(lspconfig)
  local lsp_autocmp_capabilites = require("cmp_nvim_lsp").default_capabilities()

  for server, config in pairs(get_lang_server_details()) do
    -- Autocomplete capabilities are added to all servers by default
    config.capabilities = lsp_autocmp_capabilites
    lspconfig[server].setup(config)
  end
end

-- Helper functions for language servers
function SetupClangExtn()
  require("clangd_extensions").setup({})
  -- inlay_hints is deprecated. commenting out the following code
  -- require("clangd_extensions.inlay_hints").setup_autocmd()
  -- require("clangd_extensions.inlay_hints").set_inlay_hints()
end

return {}
