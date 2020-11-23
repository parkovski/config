if !filereadable(g:vimrc_platform.dotvim . '/autoload/plug.vim')
  exe 'silent !curl -fLo ' . g:vimrc_platform.dotvim . '/autoload/plug.vim ' .
    \ '--create-dirs ' .
    \ 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  source g:vimrc_platform.dotvim . '/autoload/plug.vim'
  augroup InstallPlugins
    autocmd!
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  augroup END
endif

call plug#begin(g:vimrc_platform.dotvim . '/bundle')

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
else "if $VIM_LANGCLIENT ==? 'coc'
  Plug 'neoclide/coc.nvim', { 'branch': 'release' }
endif

Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

" Debugger
" Plug 'puremourning/vimspector'

Plug 'terryma/vim-multiple-cursors'
Plug 'embear/vim-localvimrc'
" Symbol browser
Plug 'liuchengxu/vista.vim'

Plug 'itchyny/lightline.vim'
Plug 'mgee/lightline-bufferline'

Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'

let g:rainbow_active = 1
Plug 'luochen1990/rainbow'
" Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-abolish'
Plug 'bronson/vim-visual-star-search'
" Plug 'skywind3000/asyncrun.vim'
Plug 'scrooloose/nerdtree'
Plug 'sgur/vim-editorconfig'
" Plug 'michaeljsmith/vim-indent-object'



let g:indent_guides_auto_colors = 0
let g:indent_guides_guide_size = 1
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_start_level = 2
hi link IndentGuidesOdd CursorLine
hi link IndentGuidesEven CursorLine
hi link ColorColumn CursorLine
hi link EchoDocFloat Pmenu
Plug 'nathanaelkane/vim-indent-guides'

let g:markology_include = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
Plug 'jeetsukumaran/vim-markology'

" Plug 'derekwyatt/vim-fswitch'

" Color schemes
Plug 'sonph/onehalf', {'rtp': 'vim/'}
Plug 'bluz71/vim-moonfly-colors'
Plug 'cocopon/iceberg.vim'
Plug 'chase/focuspoint-vim'
Plug 'nightsense/snow'
Plug 'rakr/vim-two-firewatch'
" Plug 'sainnhe/vim-color-desert-night' " fool removed this repo :(
Plug 'sainnhe/vim-color-forest-night'
Plug 'jacoborus/tender.vim'
Plug 'jaredgorski/spacecamp'
Plug 'marcopaganini/termschool-vim-theme'

" Syntaxes
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_concepts_highlight = 1
Plug 'bfrg/vim-cpp-modern'

Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'
Plug 'Quramy/vim-js-pretty-template'
Plug 'jason0x43/vim-js-indent'
" Plug 'Quramy/tsuquyomi'
" Plug 'ixm-one/vim-cmake'
Plug 'cespare/vim-toml'
Plug 'rust-lang/rust.vim'
Plug 'plasticboy/vim-markdown'
" Plug 'ilyachur/cmake4vim'
Plug 'pboettch/vim-cmake-syntax'

call plug#end()
