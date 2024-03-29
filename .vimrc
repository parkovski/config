set nocompatible
set autoindent
set title hidden
set tabstop=2 softtabstop=2 shiftwidth=2 expandtab
set backspace=indent,eol,start
set noerrorbells visualbell t_vb= belloff=all
set incsearch hlsearch
set ignorecase smartcase
set number relativenumber signcolumn=number
set colorcolumn=80,100,120
set textwidth=79
set cursorline
set showcmd noshowmode showtabline=2
set splitright splitbelow
set wildmenu wildmode=longest:full,full
set complete=. completeopt=menu,preview,noselect
set laststatus=2
set noswapfile backupdir-=.
set foldmethod=marker nofoldenable foldcolumn=auto:1 foldopen-=block foldlevel=99
set autoread
set encoding=utf8 fileformats=unix,dos
set mouse=a
set eol nofixeol
set cinoptions=:0,g0,N-s,E-s,t0,is,(0,U1,w1,Ws,ks,m1,j1,J1
set list listchars=tab:⇥\ ,nbsp:␣,trail:‣,precedes:«,extends:»
let &showbreak="⇒  "
let mapleader="\<space>"

"set listchars=tab:→\ ,space:·,nbsp:␣,trail:•,eol:↲,precedes:«,extends:»

if exists('&termguicolors')
  if !has('nvim')
    let &t_Co = 256
    let &t_8f = "[38;2;%lu;%lu;%lum"
    let &t_8b = "[48;2;%lu;%lu;%lum"
  endif
  set termguicolors
endif

if exists('&guifont')
  set guifont=Iosevka\ Medium:h12
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

if empty($VIM_LANGCLIENT)
  let $VIM_LANGCLIENT='lsp'
endif

source $HOME/.share/lib/vim/platform.vim
source $HOME/.share/lib/vim/headerguard.vim
if g:vimrc_platform.status_plugin ==? 'lightline'
  source $HOME/.share/lib/vim/lightline.vim
endif
source $HOME/.share/lib/vim/plugins.vim
source $HOME/.share/lib/vim/colors.vim
if g:vimrc_platform.status_plugin ==? 'lualine'
  source $HOME/.share/lib/vim/lualine.vim
endif
source $HOME/.share/lib/vim/mapping.vim

augroup VimrcAutoCommands
  autocmd!
  autocmd FileType cpp set commentstring=//%s
  autocmd FileType cmake set commentstring=#%s
  autocmd FileType javascriptreact,typescriptreact 
        \ setl cinoptions-=(0 cinoptions+=(s

  autocmd BufNewFile,BufRead *.S set filetype=asm
  autocmd BufNewFile,BufRead *.rml set filetype=html
  autocmd BufNewFile,BufRead *.rcss set filetype=css

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
  autocmd TermOpen * setlocal nonumber norelativenumber signcolumn=no foldcolumn=0
  autocmd TermEnter * startinsert
augroup END
