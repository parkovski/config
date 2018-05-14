set nocompatible
set autoindent
set number
set tabstop=2 softtabstop=2 shiftwidth=2 expandtab
set backspace=indent,eol,start
set noerrorbells
set visualbell t_vb=
set belloff=all
set incsearch hlsearch
set colorcolumn=80,100,120
set hidden
set encoding=utf8
set cursorline
set signcolumn=yes
set showcmd
set splitright
set splitbelow
set wildmode=list:longest,full
set wildmenu
set nowritebackup
set nobackup
set noswapfile
set backupdir-=.
set pumheight=20
set complete=.
set noshowmode
set laststatus=2
set t_Co=256
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

let mapleader="\<space>"

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

  call plug#begin('~/vimfiles/bundle')

  Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'pwsh install.ps1',
    \ }

  if !has('nvim') && !empty($PYTHON3DLL)
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

Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'luochen1990/rainbow'
Plug 'tpope/vim-fugitive'
"Plug 'Chilledheart/vim-clangd'
Plug 'vhdirk/vim-cmake'
Plug 'bronson/vim-visual-star-search'
" Plug 'nacitar/a.vim'
Plug 'skywind3000/asyncrun.vim'
Plug 'terryma/vim-multiple-cursors'
Plug 'scrooloose/nerdtree'
Plug 'sgur/vim-editorconfig'

Plug 'PProvost/vim-ps1'
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'plasticboy/vim-markdown'
Plug 'stephpy/vim-yaml'
Plug 'cespare/vim-toml'
Plug 'elzr/vim-json'
Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
Plug 'Quramy/tsuquyomi'
Plug 'leafo/moonscript-vim'

if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif
let g:deoplete#enable_at_startup = 1

call plug#end()

call deoplete#custom#option('auto_complete_delay', 20)
call deoplete#custom#option('auto_refresh_delay', 200)


" let g:airline_powerline_fonts = 1
" if !exists('g:airline_symbols')
"   let g:airline_symbols = {}
" endif
" let g:airline_symbols.space = "\ua0"
" let g:airline_theme='wombat'
" let g:airline#extensions#tabline#enabled = 1
" let g:airline#extensions#tabline#show_buffers = 1

let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ }

let g:rainbow_active = 1

let g:cmake_install_prefix = $CMAKE_INSTALL_PREFIX
let g:cmake_project_generator = 'Ninja'
let g:cmake_export_compile_commands = 1

let g:LanguageClient_serverCommands = {
      \ 'cpp': ['clangd.exe'],
      \ 'c': ['clangd.exe'],
      \ 'javascript': ['javascript-typescript-stdio'],
      \ 'typescript': ['javascript-typescript-stdio'],
      \ 'lua': ['lua-lsp'],
      \ }

let g:LanguageClient_autoStart = 1

" let g:deoplete#sources = {}
" let g:deoplete#sources.cpp = ['LanguageClient']
" let g:deoplete#sources.c = ['LanguageClient']
" let g:deoplete#sources.javascript = ['LanguageClient']
" let g:deoplete#sources.typescript = ['LanguageClient']
" let g:deoplete#sources.vim = ['vim']

call deoplete#initialize()

set omnifunc=LanguageClient#complete
set completefunc=LanguageClient#complete

inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"

inoremap <expr> <C-space> deoplete#manual_complete(['omni'])
inoremap <expr> <NUL> deoplete#manual_complete(['omni'])
inoremap <expr> <C-s> deoplete#manual_complete(['omni'])
inoremap <expr> <C-h> deoplete#smart_close_popup()."\<C-h>"
inoremap <expr> <BS> deoplete#smart_close_popup()."\<C-h>"
inoremap <expr> <C-g> deoplete#undo_completion()
inoremap <expr> <C-l> deoplete#refresh()
inoremap <expr> <M-space> deoplete#complete_common_string()

nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
nnoremap <silent> <leader>r :call LanguageClient#textDocument_rename()<CR>
nnoremap <silent> <C-s> :call LanguageClient#textDocument_signatureHelp()<CR>
inoremap <expr><silent> <C-s> <SID>showSignatureHelp()
" imap <expr><silent> <C-s> LanguageClient#textDocument_signatureHelp()

function! s:showSignatureHelp()
  call LanguageClient#textDocument_signatureHelp()
  return ''
endfunction

function! g:Multiple_cursors_before()
  call deoplete#custom#buffer_option('auto_complete', v:false)
endfunction
function! g:Multiple_cursors_after()
  call deoplete#custom#buffer_option('auto_complete', v:true)
endfunction

noremap <M-h> <C-w>5<
noremap <M-j> <C-w>5-
noremap <M-k> <C-w>5+
noremap <M-l> <C-w>5>
imap <M-h> <C-o><M-h>
imap <M-j> <C-o><M-j>
imap <M-k> <C-o><M-k>
imap <M-l> <C-o><M-l>

nnoremap <silent> <leader>T :bp<CR>
nnoremap <silent> <leader>t :bn<CR>
nnoremap <silent> <leader>q :bd<CR>
" nnoremap <silent> <leader>h :A<CR>
nnoremap <silent> <leader>l :noh<CR>
nnoremap <leader>: :AsyncRun<space>
vnoremap <leader>: :AsyncRun<space>
nnoremap <silent> <leader>b :NERDTreeToggle<CR>
nnoremap <silent> <leader>P
      \ :if &paste <Bar> set nopaste <Bar>
      \ else <Bar> set paste <Bar> endif<CR>

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter *
  \ if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") |
  \ exe 'NERDTree' argv()[0] | wincmd p | ene | endif
autocmd bufenter *
  \ if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) |
  \ q | endif

autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | silent! pclose | endif

noremap! <Char-0x7F> <BS>
if !has('nvim')
  set cryptmethod=blowfish2
endif

set tgc
set bg=dark
silent! execute 'colors ' . readfile(glob('~/bin/etc/vimcolor'))[0]

if !has('win32')
  let &t_SI = "\<Esc>[5 q"
  let &t_SR = "\<Esc>[3 q"
  let &t_EI = "\<Esc>[1 q"
endif
