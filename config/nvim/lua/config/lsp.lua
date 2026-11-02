-- Language-server behavior. Nix supplies every server executable on PATH.

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc, mode)
      vim.keymap.set(mode or 'n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
    map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
    map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
    map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
    map('<leader>gD', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
    map('K', function()
      vim.lsp.buf.hover { border = 'rounded' }
    end, 'Hover Documentation')
    map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')
    map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
    map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
      local highlight_group = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_group,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_group,
        callback = vim.lsp.buf.clear_references,
      })
      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
        callback = function(detach_event)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = detach_event.buf }
        end,
      })
    end

    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
      map('<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
      end, '[T]oggle Inlay [H]ints')
    end
  end,
})

-- Match the Gentoo diagnostic presentation.
vim.diagnostic.config {
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = vim.diagnostic.severity.ERROR },
  signs = vim.g.have_nerd_font and {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚 ',
      [vim.diagnostic.severity.WARN] = '󰀪 ',
      [vim.diagnostic.severity.INFO] = '󰋽 ',
      [vim.diagnostic.severity.HINT] = '󰌶 ',
    },
  } or {},
  virtual_text = {
    source = 'if_many',
    spacing = 2,
    format = function(diagnostic)
      return diagnostic.message
    end,
  },
}

local capabilities = require('blink.cmp').get_lsp_capabilities()
local servers = {
  clangd = {},
  gopls = {
    settings = {
      gopls = {
        usePlaceholders = true,
        analyses = { unusedparams = true },
      },
    },
  },
  golangci_lint_ls = {},
  html = { provideFormatter = false, filetypes = { 'html', 'htmldjango', 'php' } },
  cssls = {},
  pyright = {
    settings = {
      pyright = { disableOrganizeImports = false },
      python = { analysis = { diagnosticMode = 'workspace' } },
    },
  },
  intelephense = {},
  vue_ls = {
    init_options = { vue = { hybridMode = true } },
  },
  elixirls = {},
  -- Restrict VTSLS to Vue; typescript-tools owns JS and TypeScript buffers.
  vtsls = {
    filetypes = { 'vue' },
    settings = {
      complete_function_calls = true,
      vtsls = {
        enableMoveToFileCodeAction = true,
        autoUseWorkspaceTsdk = true,
        experimental = {
          completion = { enableServerSideFuzzyMatch = true },
        },
        tsserver = {
          globalPlugins = {
            {
              name = '@vue/typescript-plugin',
              location = vim.g.vue_language_server_path,
              languages = { 'vue' },
              configNamespace = 'typescript',
              enableForWorkspaceTypeScriptVersions = true,
            },
          },
        },
      },
      typescript = {
        updateImportsOnFileMove = { enabled = 'always' },
        suggest = { completeFunctionCalls = true },
        inlayHints = {
          enumMemberValues = { enabled = true },
          functionLikeReturnTypes = { enabled = true },
          parameterNames = { enabled = 'literals' },
          parameterTypes = { enabled = true },
          propertyDeclarationTypes = { enabled = true },
          variableTypes = { enabled = false },
        },
      },
    },
  },
  lua_ls = {
    settings = {
      Lua = { completion = { callSnippet = 'Replace' } },
    },
  },
}

-- Neovim 0.11's native LSP registry replaces Mason and mutable installs.
for name, server in pairs(servers) do
  server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
  vim.lsp.config(name, server)
  vim.lsp.enable(name)
end
