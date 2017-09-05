set nocompatible
filetype off

syntax on
set autoindent
set nu
set ts=2 sw=2 et
set bs=2
set noeb vb
set t_vb=
set incsearch hlsearch
filetype plugin indent on

if exists('+colorcolumn')
  set colorcolumn=81
else
  au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
endif

au BufRead,BufNewFile *.ts set filetype=typescript

call pathogen#infect()

if $ConEmuANSI == 'ON'
  set term=xterm
  set t_Co=256
  let &t_AB="\e[48;5;%dm"
  let &t_AF="\e[38;5;%dm"
  let &t_md="\e[101m\e[1m"
  let &t_me="\e[m"
  let &t_so="\e[101m\e[1m"
  let &t_se="\e[m"
  inoremap <Char-0x7F> <BS>
  nnoremap <Char-0x7F> <BS>
endif

colors github
set bg=dark
