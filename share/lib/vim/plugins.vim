if !filereadable(g:vimrc_platform.dotvim . '/autoload/plug.vim')
  exe 'silent !curl -fLo ' . g:vimrc_platform.dotvim . '/autoload/plug.vim ' .
    \ '--create-dirs ' .
    \ 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  source g:vimrc_platform.dotvim . '/autoload/plug.vim'
  echo "Needs PlugInstall"
  " PlugInstall --sync
endif

call plug#begin(g:vimrc_platform.dotvim . '/bundle')

" General
"Plug 'junegunn/fzf'
"Plug 'junegunn/fzf.vim'

if $VIM_LANGCLIENT ==? 'lcn'
  Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': g:vimrc_platform.lcinstall,
    \ }
  let s:sources = []
  let g:vista_default_executive = 'lcn'
elseif $VIM_LANGCLIENT ==? 'ale'
  " let g:ale_completion_enabled = 1
  let g:ale_set_balloons = 1
  Plug 'w0rp/ale'
  let s:sources = ['ale']
  let g:vista_default_executive = 'ale'
elseif $VIM_LANGCLIENT ==? 'coc'
  Plug 'neoclide/coc.nvim', { 'branch': 'release' }
  "Plug 'antoinemadec/coc-fzf'
  let g:vista_default_executive = 'coc'
elseif has('nvim') && $VIM_LANGCLIENT ==? 'lsp'
  Plug 'neovim/nvim-lspconfig'
endif

" Debugger
" Plug 'puremourning/vimspector'

" Config
let g:localvimrc_persistent = 1
let g:localvimrc_persistence_file = fnamemodify("~/.local/etc/localvimrc_persistent", ":p")
let g:localvimrc_whitelist = fnamemodify($GH, ":p").'\%(3rd-party/\)\@!.*'
" let g:localvimrc_sandbox = 0
Plug 'embear/vim-localvimrc'
Plug 'sgur/vim-editorconfig'

" Editing
" Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-abolish'
Plug 'bronson/vim-visual-star-search'
Plug 'mg979/vim-visual-multi'

let g:rainbow_active = 1

" Colors = blue, green, yellow, orange, red, violet, indigo
let g:rainbow_conf = {
      \ 'guifgs': ['#2590fa', 'chartreuse3', 'gold', 'orange2',
      \   'firebrick', 'palevioletred1', '#8840f8'],
      \ 'operators': '_,\|;_',
      \ 'separately': { 'cmake': 0 } }
Plug 'luochen1990/rainbow'

let g:markology_include = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
Plug 'jeetsukumaran/vim-markology'

let g:indent_guides_auto_colors = 1
let g:indent_guides_guide_size = 1
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_start_level = 2
" hi link IndentGuidesOdd CursorLine
" hi link IndentGuidesEven CursorLine
hi link ColorColumn CursorLine
hi link EchoDocFloat Pmenu
Plug 'nathanaelkane/vim-indent-guides'

" Panes
Plug 'liuchengxu/vista.vim' " Symbol browser
Plug 'kyazdani42/nvim-web-devicons' " for file icons
Plug 'kyazdani42/nvim-tree.lua'
"Plug 'scrooloose/nerdtree'
Plug 'kyazdani42/nvim-web-devicons'
if has("nvim") || has("lua")
  Plug 'nvim-lualine/lualine.nvim'
else
  Plug 'itchyny/lightline.vim'
  Plug 'mgee/lightline-bufferline'
endif

" Color schemes
" Plug 'sonph/onehalf', {'rtp': 'vim/'}
Plug 'bluz71/vim-moonfly-colors'
Plug 'cocopon/iceberg.vim'
Plug 'NLKNguyen/papercolor-theme'
Plug 'rhysd/vim-color-spring-night'
Plug 'joshdick/onedark.vim'
Plug 'cormacrelf/vim-colors-github'
Plug 'ajmwagar/vim-deus'
Plug 'tyrannicaltoucan/vim-quantum'
Plug 'savq/melange'
Plug 'keith/parsec.vim'
Plug 'mhartington/oceanic-next'
" Plug 'nightsense/snow'
" Plug 'rakr/vim-two-firewatch'
Plug 'sainnhe/everforest'
" Plug 'jacoborus/tender.vim'
" Plug 'jaredgorski/spacecamp'
" Plug 'marcopaganini/termschool-vim-theme'
Plug 'sainnhe/edge'

" Syntaxes
" let g:cpp_class_scope_highlight = 1
" let g:cpp_member_variable_highlight = 1
" let g:cpp_class_decl_highlight = 1
" let g:cpp_concepts_highlight = 1
Plug 'sheerun/vim-polyglot'
" Plug 'bfrg/vim-cpp-modern'
" Plug 'leafgarland/typescript-vim'
" Plug 'peitalin/vim-jsx-typescript'
" Plug 'Quramy/vim-js-pretty-template'
" Plug 'jason0x43/vim-js-indent'
" Plug 'Quramy/tsuquyomi'
" Plug 'ixm-one/vim-cmake'
" Plug 'cespare/vim-toml'
" Plug 'rust-lang/rust.vim'
" Plug 'plasticboy/vim-markdown'
" Plug 'ilyachur/cmake4vim'
" Plug 'PProvost/vim-ps1'
" Plug 'habamax/vim-godot'
" Plug 'neoclide/jsonc.vim'
" Plug 'pboettch/vim-cmake-syntax'
" Plug 'condy0919/docom.vim'
" Plug 'cstrahan/vim-capnp'

call plug#end()

if has('nvim') || has('lua')
  lua require'nvim-tree'.setup { open_on_setup = true }
endif