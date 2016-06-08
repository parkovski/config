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

colors syntastic
set bg=dark
