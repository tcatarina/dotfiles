-- Which-key, LSP progress, TypeScript, license, and tmux integrations.

require('fidget').setup {}

require('which-key').setup {
  delay = 0,
  icons = {
    mappings = vim.g.have_nerd_font,
    keys = vim.g.have_nerd_font and {} or {
      Up = '<Up> ',
      Down = '<Down> ',
      Left = '<Left> ',
      Right = '<Right> ',
      C = '<C-…> ',
      M = '<M-…> ',
      D = '<D-…> ',
      S = '<S-…> ',
      CR = '<CR> ',
      Esc = '<Esc> ',
      ScrollWheelDown = '<ScrollWheelDown> ',
      ScrollWheelUp = '<ScrollWheelUp> ',
      NL = '<NL> ',
      BS = '<BS> ',
      Space = '<Space> ',
      Tab = '<Tab> ',
      F1 = '<F1>',
      F2 = '<F2>',
      F3 = '<F3>',
      F4 = '<F4>',
      F5 = '<F5>',
      F6 = '<F6>',
      F7 = '<F7>',
      F8 = '<F8>',
      F9 = '<F9>',
      F10 = '<F10>',
      F11 = '<F11>',
      F12 = '<F12>',
    },
  },
  spec = {
    { '<leader>s', group = '[S]earch' },
    { '<leader>t', group = '[T]oggle' },
    { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
  },
}

-- TypeScript Tools owns JS/TS buffers; VTSLS is restricted to Vue in lsp.lua.
require('typescript-tools').setup {
  filetypes = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
  },
  settings = {
    tsserver_max_memory = 'auto',
    tsserver_plugins = { '@vue/typescript-plugin' },
    tsserver_file_preferences = {
      'javascript',
      'javascriptreact',
      'javascript.jsx',
      'typescript',
      'typescriptreact',
      'typescript.tsx',
      includeInlayParameterNameHints = 'all',
      includeCompletionsForModuleExports = true,
      quotePreference = 'auto',
    },
    tsserver_preferences = {},
    expose_as_code_action = 'all',
  },
}

require('licenses').setup {
  copyright_holder = 'Lucas Barbieri',
  email = 'lucas@jabuxas.com',
  license = 'MIT',
}

-- Seamless Ctrl-h/j/k/l navigation crosses Neovim and tmux pane boundaries.
local navigation = require 'nvim-tmux-navigation'
navigation.setup { disable_when_zoomed = true }
vim.keymap.set('n', '<C-h>', navigation.NvimTmuxNavigateLeft)
vim.keymap.set('n', '<C-j>', navigation.NvimTmuxNavigateDown)
vim.keymap.set('n', '<C-k>', navigation.NvimTmuxNavigateUp)
vim.keymap.set('n', '<C-l>', navigation.NvimTmuxNavigateRight)
vim.keymap.set('n', '<C-\\>', navigation.NvimTmuxNavigateLastActive)
vim.keymap.set('n', '<C-Space>', navigation.NvimTmuxNavigateNext)
