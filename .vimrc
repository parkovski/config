set nocompatible
filetype off

syntax on
set autoindent
set nu
set ts=2 sts=2 sw=2 et
set bs=indent,eol,start
set noeb vb
set t_vb=
set incsearch hlsearch
filetype plugin indent on

if exists('+colorcolumn')
  set colorcolumn=81
else
  au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
endif

call pathogen#infect()
setglobal nosmarttab
let &sts=&tabstop

if has('win32')
  let &shell = "C:\\Program Files\\PowerShell\\6.0.0-rc\\pwsh.exe"
  if $ConEmuANSI == 'ON'
    set term=xterm
    set t_Co=256
    let &t_AB="\e[48;5;%dm"
    let &t_AF="\e[38;5;%dm"
    let &t_md="\e[101m\e[1m"
    let &t_me="\e[m"
    let &t_so="\e[101m\e[1m"
    let &t_se="\e[m"
  endif

  set t_Co=256
  set t_8f="\e[38;2;%lu;%lu;%lum"
  set t_8b="\e[48;2;%lu;%lu;%lum"
endif

noremap! <Char-0x7F> <BS>
set cm=blowfish2

silent! colors antares
set bg=dark
set tgc
