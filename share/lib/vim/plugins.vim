if !filereadable($HOME . '/.vim/autoload/plug.vim')
  exe 'silent !curl -fLo ' . $HOME . '/.vim/autoload/plug.vim ' .
    \ '--create-dirs ' .
    \ 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  source $HOME . '/.vim/autoload/plug.vim'
  echo "Needs PlugInstall"
  " PlugInstall --sync
endif

call plug#begin($HOME . '/.vim/bundle')

Plug 'neovim/nvim-lspconfig'
let g:vista_default_executive = 'nvim_lsp'

Plug 'nvim-treesitter/nvim-treesitter'

" Org mode
Plug 'nvim-orgmode/orgmode'

" Config
let g:localvimrc_persistent = 1
let g:localvimrc_persistence_file = fnamemodify("~/.local/etc/localvimrc_persistent", ":p")
let g:localvimrc_whitelist = fnamemodify($GH, ":p").'\%(3p\)\/\@!.*'
" let g:localvimrc_sandbox = 0
Plug 'embear/vim-localvimrc'
Plug 'sgur/vim-editorconfig'

" Autocomplete
let g:coq_settings = {
      \   'clients': {
      \     'tmux': { 'enabled': v:false },
      \     'buffer': { 'weight_adjust': -0.25 },
      \     'lsp': { 'weight_adjust': 1.5 },
      \     'treesitter': { 'weight_adjust': 1.0 },
      \   },
      \   'keymap': { 'recommended': v:false },
      \ }
Plug 'ms-jpq/coq_nvim', {'branch': 'coq'} " Completion
Plug 'ms-jpq/coq.artifacts', {'branch': 'artifacts'} " Snippets
Plug 'ms-jpq/coq.thirdparty', {'branch': '3p'} " Extras

" Editing
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-abolish'
Plug 'bronson/vim-visual-star-search'
Plug 'mg979/vim-visual-multi'
Plug 'windwp/nvim-autopairs'
Plug 'uga-rosa/ccc.nvim'
Plug 'chrisgrieser/nvim-spider'
Plug 'lewis6991/gitsigns.nvim'

let g:rainbow_active = 0 " Enabled in colors.vim.
" Colors = blue, green, yellow, orange, red, violet, indigo
let g:rainbow_colors = {
      \   'dark': [
      \     '#2590fa', 'chartreuse3', 'gold', 'orange2',
      \     'firebrick', 'palevioletred1', '#8840f8'
      \   ],
      \   'light': [
      \     '#2860d8', '#108a28', '#e0a800', '#f86800',
      \     '#d82820', '#e830a8', '#663399'
      \   ]
      \ }
let g:rainbow_conf = {
      \ 'guifgs': [],
      \ 'guis': ['bold'],
      \ 'operators': '_,\|;_',
      \ 'separately': { 'cmake': 0 } }
Plug 'luochen1990/rainbow'

let g:markology_include = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
Plug 'jeetsukumaran/vim-markology'

let g:indent_guides_auto_colors = 1
let g:indent_guides_guide_size = 1
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_start_level = 2
"hi link ColorColumn CursorLine
"hi link EchoDocFloat Pmenu
Plug 'nathanaelkane/vim-indent-guides'

" Panes
Plug 'liuchengxu/vista.vim' " Symbol browser
Plug 'kyazdani42/nvim-web-devicons' " for file icons
Plug 'kyazdani42/nvim-tree.lua'
Plug 'nvim-lualine/lualine.nvim'

" Color schemes
Plug 'bluz71/vim-moonfly-colors'
Plug 'bluz71/vim-nightfly-colors'
Plug 'cocopon/iceberg.vim'
Plug 'NLKNguyen/papercolor-theme'
Plug 'rhysd/vim-color-spring-night'
Plug 'joshdick/onedark.vim'
Plug 'cormacrelf/vim-colors-github'
Plug 'ajmwagar/vim-deus'
Plug 'tyrannicaltoucan/vim-quantum'
Plug 'savq/melange'
Plug 'mhartington/oceanic-next'
Plug 'rakr/vim-two-firewatch'
Plug 'sainnhe/everforest'
Plug 'sainnhe/edge'
let g:sonokai_style = 'atlantis'
Plug 'sainnhe/sonokai'
Plug 'preservim/vim-colors-pencil'
Plug 'rebelot/kanagawa.nvim'
Plug 'rose-pine/neovim', { 'as': 'rose-pine' }
Plug 'cocopon/iceberg.vim'
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
Plug 'Shatur/neovim-ayu'
Plug 'uloco/bluloco.nvim'
Plug 'miikanissi/modus-themes.nvim'
Plug 'uhs-robert/oasis.nvim'
Plug 'datsfilipe/vesper.nvim'

" Syntaxes
let g:vim_svelte_plugin_use_typescript = 1
Plug 'sheerun/vim-polyglot'

call plug#end()

if has('nvim') || has('lua')
  source $HOME/.share/lib/vim/lsp.lua
lua <<EOF
  require'nvim-autopairs'.setup{}
  require'nvim-tree'.setup{}
  require'orgmode'.setup{
    org_agenda_files = '~/Documents/Sync/org',
    org_default_notes_file = '~/Documents/Sync/org/default.org',
  }
  require'gitsigns'.setup{
    signcolumn = false,
    numhl = true,
  }
EOF
endif
