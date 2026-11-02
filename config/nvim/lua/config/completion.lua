-- Lua development metadata, snippets, and completion UI.
-- Nix places every plugin on runtimepath before this setup runs.

require('lazydev').setup {
  library = {
    { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
  },
}

require('luasnip').setup {}
require('luasnip.loaders.from_vscode').lazy_load()

require('blink.cmp').setup {
  keymap = { preset = 'default' },
  appearance = { nerd_font_variant = 'mono' },
  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 1000 },
  },
  sources = {
    default = { 'lsp', 'path', 'snippets', 'lazydev' },
    providers = {
      lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
    },
  },
  snippets = { preset = 'luasnip' },
  -- Keep the pure-Lua matcher so the plugin never downloads a prebuilt binary.
  fuzzy = { implementation = 'lua' },
  signature = { enabled = true },
}
