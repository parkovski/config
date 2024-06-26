-- https://github.com/neovim/nvim-lspconfig/tree/master/lua/lspconfig/server_configurations

local lspconfig = require'lspconfig'
local coq = require'coq'
local configs = require'lspconfig.configs'

vim.diagnostic.config{
  virtual_text = { prefix = '<' }
}

local on_attach = function(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  vim.api.nvim_buf_set_option(bufnr, 'formatexpr', 'v:lua.vim.lsp.formatexpr')

  -- vim.keymap.set('i', '<C-Space>', '<C-x><C-o>', { silent=true, buffer=bufnr })

  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, bufopts)
  vim.keymap.set('n', '<space>L', vim.diagnostic.setloclist, bufopts)
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, bufopts)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, bufopts)
  -- vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  -- vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  -- vim.keymap.set('n', '<space>wl', function()
  --   print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  -- end, bufopts)
  vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<F12>', vim.lsp.buf.code_action, bufopts)
  -- vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)

  -- vim.keymap.set('n', '<M-f>', function () vim.lsp.buf.code_action({ only = 'quickfix' }) end, bufopts)

  if vim.fn.exists(':ClangdSwitchSourceHeader') then
    vim.keymap.set('n', 'gh', ':ClangdSwitchSourceHeader<CR>', bufopts)
  end

  vim.api.nvim_create_autocmd("CursorHold", {
    buffer = bufnr,
    callback = function()
      local opts = {
        focusable = false,
        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        border = 'rounded',
        source = 'always',
        prefix = ' ',
        scope = 'cursor',
      }
      vim.diagnostic.open_float(nil, opts)
    end
  })
end

local setup = function(name, settings)
  settings = settings or {}
  settings.on_attach = on_attach
  lspconfig[name].setup(
    coq.lsp_ensure_capabilities(
      settings
    )
  )
end

-- typescript-language-server
setup 'tsserver'

setup 'clangd'

-- pip cmake-language-server
setup 'cmake'

setup 'gdscript'

-- lua-language-server
setup 'lua_ls'

-- vim-language-server
setup 'vimls'

-- bash-language-server
setup 'bashls'

-- vscode-langservers-extracted
setup 'cssls'
setup 'html'
setup 'jsonls'
if not configs.markdownls then
  -- TODO import path
  local oldpath = package.path
  package.path = vim.env.HOME .. '/.share/lib/vim/?.lua'
  configs.markdownls = require'markdownls'
  package.path = oldpath
end
setup 'markdownls'

setup 'svelte'

if vim.fn.has('win32') == 1 then
  setup('omnisharp', {
      cmd = { "dotnet", "C:\\Users\\parker\\.local\\etc\\OmniSharp\\OmniSharp.dll" }
  })
else
  setup('omnisharp', {
      cmd = { "dotnet", "/usr/lib/omnisharp-roslyn/OmniSharp.dll" }
  })
end

-- setup 'cssmodules_ls'
-- setup 'glslls'
-- setup 'jedi_language_server'
-- setup 'powershell_es'
-- setup 'rust_analyzer'
