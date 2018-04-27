set nocompatible
set autoindent
set nu
set ts=2 sts=2 sw=2 et
set bs=indent,eol,start
set noeb vb
let &t_vb=''
set incsearch hlsearch
set colorcolumn=81
let &sts=&tabstop
set hidden
set encoding=utf8
set cursorline
set signcolumn=yes

if !empty($VIMTERM)
  let &term=$VIMTERM
endif

if has('win32')
  let &shell = "pwsh.exe"
  if empty(glob('~/vimfiles/autoload/plug.vim'))
    silent !pwsh -c mkdir -ea Ignore $HOME/vimfiles/autoload;
      \ (New-Object Net.WebClient).DownloadFile(
        \ 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim',
        \ $HOME + '/vimfiles/autoload/plug.vim'
      \ )
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  endif

  set t_Co=256
  set t_8f="\e[38;2;%lu;%lu;%lum"
  set t_8b="\e[48;2;%lu;%lu;%lum"

  call plug#begin('~/vimfiles/bundle')

  Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'pwsh install.ps1',
    \ }

  if !empty($PYTHON3DLL)
    let &pythonthreedll=$PYTHON3DLL
  endif
else
  if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  endif

  call plug#begin('~/.vim/bundle')

  Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }
endif

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'PProvost/vim-ps1'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-surround'
Plug 'luochen1990/rainbow'
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'tpope/vim-fugitive'
"Plug 'Chilledheart/vim-clangd'
Plug 'vhdirk/vim-cmake'

if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif
let g:deoplete#enable_at_startup = 1

call plug#end()

let g:airline_powerline_fonts = 1
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline_symbols.space = "\ua0"
let g:airline_theme='wombat'

let g:rainbow_active = 1

let g:cmake_install_prefix = $CMAKE_INSTALL_PREFIX
let g:cmake_project_generator = 'Ninja'
let g:cmake_export_compile_commands = 1

let g:LanguageClient_serverCommands = {
      \ 'cpp': ['clangd.exe'],
      \ }

let g:deoplete#sources = {}
let g:deoplete#sources.cpp = ['LanguageClient']
let g:deoplete#sources.c = ['LanguageClient']
let g:deoplete#sources.vim = ['vim']

nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
nnoremap <silent> <F2> :call LanguageClient#textDocument_rename()<CR>

inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"

"imap <c-space> <Plug>(asyncomplete_force_refresh)

noremap <M-h> <C-w>5<
noremap <M-j> <C-w>5-
noremap <M-k> <C-w>5+
noremap <M-l> <C-w>5>

autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif

let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
noremap! <Char-0x7F> <BS>
set cm=blowfish2

set tgc
set bg=dark
silent! execute 'colors ' . readfile(glob('~/bin/etc/vimcolor'))[0]

if !has('win32')
  let &t_SI = "\<Esc>[5 q"
  let &t_SR = "\<Esc>[3 q"
  let &t_EI = "\<Esc>[1 q"
endif
