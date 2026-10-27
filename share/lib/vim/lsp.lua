-- https://github.com/neovim/nvim-lspconfig/tree/master/lua/lspconfig/server_configurations

local configs = require'lspconfig.configs'

vim.diagnostic.config{
  virtual_text = { prefix = '<' }
}

local on_attach = function(client, bufnr)
  vim.keymap.set('i', '<C-Space>', '<C-x><C-u>', { silent=true, buffer=bufnr })
  vim.keymap.set('i', '<C-_>', '<C-x><C-u>', { silent=true, buffer=bufnr })

  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  --vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
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

  vim.keymap.set('n', '<M-f>', function () vim.lsp.buf.code_action({ only = 'quickfix' }) end, bufopts)

  if vim.fn.exists(':ClangdSwitchSourceHeader') then
    vim.keymap.set('n', 'gh', ':ClangdSwitchSourceHeader<CR>', bufopts)
  end
end

local setup = function(name, settings)
  settings = settings or {}
  settings.on_attach = on_attach
  vim.lsp.config(name, settings)
  vim.lsp.enable(name)
end

setup 'tsc'

setup 'clangd'

-- pip cmake-language-server
-- setup 'cmake'

-- setup 'gdscript'

-- lua-language-server
setup('lua_ls', {
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if
        path ~= vim.fn.stdpath('config')
        and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
      then
        return
      end
    end

    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
      runtime = {
        -- Tell the language server which version of Lua you're using (most
        -- likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
        -- Tell the language server how to find Lua modules same way as Neovim
        -- (see `:h lua-module-load`)
        path = {
          'lua/?.lua',
          'lua/?/init.lua',
        },
      },
      -- Make the server aware of Neovim runtime files
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
          -- For LSP Settings Type Annotations: https://github.com/neovim/nvim-lspconfig#lsp-settings-type-annotations
          vim.api.nvim_get_runtime_file("lua/lspconfig", false)[1],
        },
        -- Or pull in all of 'runtimepath'.
        -- NOTE: this is a lot slower and will cause issues when working on
        -- your own configuration.
        -- See https://github.com/neovim/nvim-lspconfig/issues/3189
        -- library = vim.api.nvim_get_runtime_file('', true),
      },
    })
  end,
  settings = {
    Lua = {},
  },
})

-- vim-language-server
setup 'vimls'

-- bash-language-server
-- setup 'bashls'

-- vscode-langservers-extracted
setup 'cssls'
setup 'html'
setup 'jsonls'
--[[if not configs.markdownls then
  -- TODO import path
  local oldpath = package.path
  package.path = vim.env.HOME .. '/.share/lib/vim/?.lua'
  setup 'markdownls'
  configs.markdownls = require'markdownls'
  package.path = oldpath
end]]

setup 'svelte'

setup 'omnisharp'

-- setup('powershell_es', {
--   bundle_path = vim.env.HOME .. '/.local/etc'
-- })

-- setup 'rust_analyzer'
