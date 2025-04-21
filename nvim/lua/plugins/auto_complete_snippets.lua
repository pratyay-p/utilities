return {
  {
    -- A snippet provider: extend it with other snippet
    -- provider like honza/vim-snippets
    "L3MON4D3/LuaSnip",         
    lazy = true,
    version = "2.0.0",
  },
  {
    -- Source form snippets for L3M0N4D3/LuaSnip
    "saadparwaiz1/cmp_luasnip",
    lazy = true,
    dependencies = {
      "L3MON4D3/LuaSnip",
    },
  },
  {
    -- Peep info about types or decls using a inline window; For key map,
    -- see https://github.com/rmagatti/goto-preview#%EF%B8%8F-mappings
    "rmagatti/goto-preview",
    lazy = true,
    opts = {
      default_mappings = true,
    },
  },
}
