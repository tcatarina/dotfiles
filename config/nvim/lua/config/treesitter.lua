-- Treesitter parsers and queries are bundled by Nix; this module only enables them.
-- The pinned plugin uses Neovim's current native highlighting API, not configs.setup.

require('nvim-treesitter').setup {}

-- Start highlighting wherever a bundled parser exists and enable experimental indentation.
vim.api.nvim_create_autocmd('FileType', {
  pattern = '*',
  callback = function(event)
    local started = pcall(vim.treesitter.start, event.buf)
    if started and vim.bo[event.buf].filetype ~= 'ruby' then
      vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})
