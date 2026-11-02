-- Portable restore of the Home Manager configuration; plugins live in site/pack/hm/start.
-- External executables are supplied by the system; this file performs no downloads.
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0

-- Resolve the Vue package from its installed executable rather than a Nix store path.
local vue_executable = vim.fn.exepath 'vue-language-server'
if vue_executable ~= '' then
  local resolved = vim.uv.fs_realpath(vue_executable) or vue_executable
  local package_root = vim.fs.dirname(vim.fs.dirname(resolved))
  if vim.fn.filereadable(package_root .. '/package.json') == 1 then
    vim.g.vue_language_server_path = package_root
  end
end

-- Keep an 80-column guide only in the active window.
vim.opt.colorcolumn = '80'
local autocmd = vim.api.nvim_create_autocmd
autocmd('WinLeave', {
  pattern = '*',
  callback = function()
    vim.opt.colorcolumn = '0'
  end,
})
autocmd('WinEnter', {
  pattern = '*',
  callback = function()
    vim.opt.colorcolumn = '80'
  end,
})

-- Preserve the concise comment-aware formatting behavior from Gentoo.
autocmd('FileType', {
  pattern = '*',
  callback = function()
    vim.o.formatoptions = 'jql'
  end,
})

-- Rename the surrounding tmux window to the current file while Neovim is active.
if vim.env.TMUX then
  local group = vim.api.nvim_create_augroup('TmuxWindowRename', { clear = true })
  vim.api.nvim_create_autocmd({ 'BufEnter', 'FocusGained' }, {
    group = group,
    callback = function()
      local filename = vim.fn.expand '%:t'
      if filename == '' then
        filename = '*scratch*'
      end
      vim.fn.system { 'tmux', 'rename-window', filename }
    end,
  })
  vim.api.nvim_create_autocmd('VimLeave', {
    group = group,
    callback = function()
      vim.fn.system { 'tmux', 'set-window-option', 'automatic-rename', 'on' }
    end,
  })
end

-- Editing defaults.
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.swapfile = false
vim.opt.title = true
vim.opt.titlestring = '%F'
vim.opt.backup = false
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = false
vim.o.relativenumber = true
vim.o.mouse = 'a'
vim.o.showmode = false
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.smartindent = true
vim.o.signcolumn = 'yes'
vim.opt.isfname:append '@-@'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true

-- Global navigation, diagnostics, buffers, splits, and editing keymaps.
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<leader>nd', vim.diagnostic.goto_next, { desc = '[N]ext [D]iagnostic' })
vim.keymap.set('n', '<leader>pd', vim.diagnostic.goto_prev, { desc = '[P]revious [D]iagnostic' })
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Show [D]iagnostic details' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.keymap.set('n', '<S-l>', '<cmd>bnext<CR>', { desc = 'Go to next Buffer' })
vim.keymap.set('n', '<S-h>', '<cmd>bprev<CR>', { desc = 'Go to previous Buffer' })
vim.keymap.set('n', '<S-q>', '<cmd>bdelete<CR>', { desc = 'Delete current buffer' })
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")
vim.keymap.set('n', '<S-w>', '"xdiwdwep"xp', { desc = 'Swap current word with next' })
vim.keymap.set('v', '>', '>gv', { desc = 'Indent and keep selection' })
vim.keymap.set('v', '<', '<gv', { desc = 'Unindent and keep selection' })
vim.keymap.set('n', '<leader>sv', ':vsplit<CR>', { noremap = true, silent = true, desc = 'Split Vertically' })

-- Briefly highlight copied text.
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Add the restored start packages before loading the original plugin configuration.
vim.cmd.packloadall()
require 'config.appearance'
require 'config.telescope'
require 'config.completion'
require 'config.lsp'
require 'config.formatting'
require 'config.treesitter'
require 'config.debug'
require 'config.integrations'
