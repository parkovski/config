set nocompatible
set autoindent
set title hidden
set tabstop=2 softtabstop=2 shiftwidth=2 expandtab
set backspace=indent,eol,start
set noerrorbells visualbell t_vb= belloff=all
set incsearch hlsearch
set ignorecase smartcase
set number relativenumber signcolumn=yes
set colorcolumn=80,100,120
set cursorline
set showcmd noshowmode showtabline=2
set splitright splitbelow
set wildmenu wildmode=longest:full,full
set complete=. completeopt=menu,preview,noselect
set laststatus=2
set nobackup nowritebackup noswapfile backupdir-=.
set foldmethod=marker nofoldenable foldcolumn=1
set autoread
set encoding=utf8 fileformats=unix,dos
set mouse=a
set noeol nofixeol
set cinoptions=g0,N-s,t0,(0,U1,ws,Ws,m1,js,Js
set listchars=tab:→\ ,space:·,nbsp:␣,trail:•,eol:↲,precedes:«,extends:»
let &showbreak="=>> "
let mapleader="\<space>"

if exists('&termguicolors')
  set termguicolors
  if !has('nvim')
    let &t_Co = 256
    " let &t_8f = "[38;2;%lu;%lu;%lum"
    " let &t_8b = "[48;2;%lu;%lu;%lum"
  endif
endif

if exists('+pyxversion')
  set pyxversion=3
endif

if has('win32')
  " AAAAAAGGGGGHHHHH
  map <C-z> <Nop>
endif

if exists('&cryptmethod')
  set cryptmethod=blowfish2
endif

let $VIM_LANGCLIENT='coc'

source $HOME/shared/lib/vim/platform.vim
source $HOME/shared/lib/vim/lightline.vim
source $HOME/shared/lib/vim/plugins.vim
source $HOME/shared/lib/vim/mapping.vim
source $HOME/shared/lib/vim/colors.vim

augroup VimrcAutoCommands
  autocmd!
  autocmd FileType cpp set commentstring=//%s
  autocmd FileType cmake set commentstring=#%s

  autocmd StdinReadPre * let s:std_in=1
  if exists("b:NERDTree")
    autocmd VimEnter *
      \ if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") |
      \ exe 'NERDTree' argv()[0] | wincmd p | ene | endif
    autocmd BufEnter *
      \ if winnr("$") == 1 && b:NERDTree.isTabTree() |
      \ q | endif
  endif

  autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | silent! pclose | endif
augroup END
