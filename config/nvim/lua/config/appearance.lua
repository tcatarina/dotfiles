-- Visual, editing-assistance, file-tree, and Git gutter plugins.

require('guess-indent').setup {}

-- Configure Git signs once, combining the Gentoo base signs and attachment maps.
require('gitsigns').setup {
  current_line_blame = true,
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
  on_attach = function(bufnr)
    local gitsigns = require 'gitsigns'
    local function map(mode, lhs, rhs, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    map('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal { ']c', bang = true }
      else
        gitsigns.nav_hunk 'next'
      end
    end, { desc = 'Jump to next git [c]hange' })
    map('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal { '[c', bang = true }
      else
        gitsigns.nav_hunk 'prev'
      end
    end, { desc = 'Jump to previous git [c]hange' })

    map('v', '<leader>hs', function()
      gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
    end, { desc = 'git [s]tage hunk' })
    map('v', '<leader>hr', function()
      gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
    end, { desc = 'git [r]eset hunk' })
    map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'git [s]tage hunk' })
    map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk' })
    map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer' })
    map('n', '<leader>hu', gitsigns.stage_hunk, { desc = 'git [u]ndo stage hunk' })
    map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'git [R]eset buffer' })
    map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'git [p]review hunk' })
    map('n', '<leader>hb', gitsigns.blame_line, { desc = 'git [b]lame line' })
    map('n', '<leader>hd', gitsigns.diffthis, { desc = 'git [d]iff against index' })
    map('n', '<leader>hD', function()
      gitsigns.diffthis '@'
    end, { desc = 'git [D]iff against last commit' })
    map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle git show [b]lame line' })
    map('n', '<leader>tD', gitsigns.preview_hunk_inline, { desc = '[T]oggle git show [D]eleted' })
  end,
}

-- Gruvbox colors and the exact transparent/floating-window highlights from Gentoo.
require('gruvbox').setup {
  terminal_colors = true,
  transparent_mode = true,
}
vim.cmd.colorscheme 'gruvbox'
vim.api.nvim_set_hl(0, 'LineNr', { bg = 'none' })
vim.api.nvim_set_hl(0, 'CursorLineNr', { bg = 'none' })
vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'none' })
vim.api.nvim_set_hl(0, 'IblIndent', { fg = '#3c3836', bg = 'none' })
vim.api.nvim_set_hl(0, 'IblScope', { fg = '#665c54', bg = 'none' })
vim.api.nvim_set_hl(0, 'NormalFloat', { bg = '#1d2021' })
vim.api.nvim_set_hl(0, 'FloatBorder', { fg = '#ffffff', bg = '#1d2021' })

require('todo-comments').setup { signs = false }
require('ibl').setup {}
require('nvim-autopairs').setup {}

-- Mini supplies text objects, surrounds, and the compact LINE:COLUMN statusline.
require('mini.ai').setup { n_lines = 500 }
require('mini.surround').setup()
local statusline = require 'mini.statusline'
statusline.setup { use_icons = vim.g.have_nerd_font }
statusline.section_location = function()
  return '%2l:%-2v'
end

-- Neo-tree uses backslash to reveal the current file and close its own window.
require('neo-tree').setup {
  filesystem = {
    window = {
      mappings = { ['\\'] = 'close_window' },
    },
  },
}
vim.keymap.set('n', '\\', ':Neotree reveal<CR>', { desc = 'NeoTree reveal', silent = true })
