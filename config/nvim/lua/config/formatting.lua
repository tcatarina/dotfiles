-- Format-on-save and Markdown linting backed entirely by Nix packages.

local conform = require 'conform'
local prettier = { 'prettierd', 'prettier', stop_after_first = true }
conform.setup {
  notify_on_error = false,
  format_on_save = function(bufnr)
    -- C and C++ intentionally remain manual because their style is project-specific.
    if ({ c = true, cpp = true })[vim.bo[bufnr].filetype] then
      return nil
    end
    return { timeout_ms = 500, lsp_format = 'fallback' }
  end,
  formatters_by_ft = {
    lua = { 'stylua' },
    python = { 'ruff', 'black', stop_after_first = true },
    go = { 'goimports', 'gofumpt' },
    php = { 'phpcbf', 'php_cs_fixer', stop_after_first = true },
    javascript = prettier,
    typescript = prettier,
    typescriptreact = prettier,
    javascriptreact = prettier,
    vue = prettier,
    html = prettier,
    css = prettier,
    json = prettier,
  },
}
vim.keymap.set({ 'n', 'v' }, '<leader>f', function()
  conform.format { async = true, lsp_format = 'fallback' }
end, { desc = '[F]ormat buffer' })

-- Lint only Markdown and only modifiable buffers, avoiding popup noise.
local lint = require 'lint'
lint.linters_by_ft = { markdown = { 'markdownlint' } }
local lint_group = vim.api.nvim_create_augroup('lint', { clear = true })
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
  group = lint_group,
  callback = function()
    if vim.bo.modifiable then
      lint.try_lint()
    end
  end,
})
