local util = require 'lspconfig.util'

local bin_name = 'vscode-markdown-language-server'
local cmd = { bin_name, '--stdio' }

if vim.fn.has 'win32' == 1 then
  cmd = { 'cmd.exe', '/C', bin_name, '--stdio' }
end

return {
  default_config = {
    cmd = cmd,
    filetypes = { 'md', 'mdx' },
    init_options = {
      provideFormatter = true,
    },
    root_dir = util.find_git_ancestor,
    single_file_support = true,
  },
  docs = {
    -- this language server config is in VSCode built-in package.json
    description = [[
https://github.com/hrsh7th/vscode-langservers-extracted
vscode-markdown-language-server, a language server for markdown
`vscode-markdown-language-server` can be installed via `npm`:
```sh
npm i -g vscode-langservers-extracted
```
]],
    default_config = {
      root_dir = [[util.find_git_ancestor]],
    },
  },
}
