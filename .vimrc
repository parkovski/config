set nocompatible
set autoindent
set number
set tabstop=2 softtabstop=2 shiftwidth=2 expandtab
set backspace=indent,eol,start
set noerrorbells
set visualbell t_vb=
set belloff=all
set incsearch hlsearch
set smartcase
set colorcolumn=80,100,120
set hidden
set encoding=utf8
set cursorline
set signcolumn=yes
set showcmd
set splitright
set splitbelow
set wildmode=longest:full,full
set wildmenu
set nowritebackup
set nobackup
set noswapfile
set backupdir-=.
set autoread
set pumheight=20
set complete=.
set noshowmode
set laststatus=2
set showtabline=2
set t_Co=256
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

let mapleader="\<space>"

if !empty($VIMTERM)
  let &term=$VIMTERM
endif

let g:vimrc_platform = {}

if has('win32')
  let &shell = "pwsh.exe"
  if empty(glob('~/vimfiles/autoload/plug.vim'))
    silent !pwsh -c mkdir -ea Ignore $HOME/vimfiles/autoload;
      \ (New-Object Net.WebClient).DownloadFile(
        \ 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim',
        \ $HOME + '/vimfiles/autoload/plug.vim'
      \ )
    augroup InstallPlugins
      autocmd!
      autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
    augroup END
  endif

  if exists('&pythonthreedll') && !empty($PYTHON3DLL)
    let &pythonthreedll=$PYTHON3DLL
  endif

  let g:vimrc_platform.dotvim = glob('~/vimfiles')
  let g:vimrc_platform.temp = $TEMP
  let g:vimrc_platform.lcinstall = 'pwsh install.ps1'
  let g:vimrc_platform.cquery_exe = exepath('cquery.exe')
  if empty(g:vimrc_platform.cquery_exe)
    let g:vimrc_platform.cquery_exe = glob('~/bin/cquery/bin/cquery.exe')
  endif
else
  if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    augroup InstallPlugins
      autocmd!
      autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
    augroup END
  endif

  let g:vimrc_platform.dotvim = glob('~/.vim')
  let g:vimrc_platform.temp = '/tmp'
  let g:vimrc_platform.lcinstall = 'bash install.sh'
  let g:vimrc_platform.cquery_exe = exepath('cquery')
  if empty(g:vimrc_platform.cquery_exe)
    g:vimrc_platform.cquery_exe = glob('~/bin/cquery/bin/cquery')
    if empty(g:vimrc_platform.cquery_exe)
      g:vimrc_platform.cquery_exe = exepath('cquery.exe')
      if empty(g:vimrc_platform.cquery_exe)
        g:vimrc_platform.cquery_exe = glob('~/bin/cquery/bin/cquery.exe')
      endif
    endif
  endif
endif

call plug#begin(g:vimrc_platform.dotvim . '/bundle')

Plug 'autozimu/LanguageClient-neovim', {
  \ 'branch': 'next',
  \ 'do': g:vimrc_platform.lcinstall,
  \ }

Plug 'itchyny/lightline.vim'
Plug 'mgee/lightline-bufferline'
" Plug 'tpope/vim-vinegar'
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
Plug 'Shougo/echodoc.vim'

Plug 'PProvost/vim-ps1'
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'plasticboy/vim-markdown'
Plug 'stephpy/vim-yaml'
Plug 'cespare/vim-toml'
Plug 'elzr/vim-json'
Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
Plug 'Quramy/tsuquyomi'
" Plug 'leafo/moonscript-vim'
Plug 'Shougo/neco-vim'

if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif

let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'tabline': {'left': [['buffers']], 'right': [['tabs']]},
      \ 'component_expand': {'buffers': 'lightline#bufferline#buffers'},
      \ 'component_type': {'buffers': 'tabsel'}
      \ }

let g:lightline#bufferline#show_number = 1
let g:lightline#bufferline#unnamed = '[No Name]'

let g:rainbow_active = 1

let g:cmake_install_prefix = $CMAKE_INSTALL_PREFIX
let g:cmake_project_generator = 'Ninja'
let g:cmake_export_compile_commands = 1

let g:deoplete#enable_at_startup = 1

call plug#end()

let g:LanguageClient_serverCommands = {
      \ 'cpp': [g:vimrc_platform.cquery_exe, '--log-file=' . g:vimrc_platform.temp . '/cquery.log'],
      \ 'c': [g:vimrc_platform.cquery_exe, '--log-file=' . g:vimrc_platform.temp . '/cquery.log'],
      \ 'javascript': ['javascript-typescript-stdio'],
      \ 'typescript': ['javascript-typescript-stdio'],
      \ 'lua': ['lua-lsp'],
      \ }

let g:LanguageClient_autoStart = 1
let g:LanguageClient_loadSettings = 1
let g:LanguageClient_settingsPath = g:vimrc_platform.dotvim . '/settings.json'
let g:LanguageClient_loggingFile = g:vimrc_platform.temp . '/lc-neovim.log'
let g:LanguageClient_loggingLevel = 'WARN'
let g:LanguageClient_serverStderr = g:vimrc_platform.temp . '/lc-server-err.log'
let g:LanguageClient_hasSnippetSupport = 1
" let g:LanguageClient_waitOutputTimeout = 5

silent call deoplete#custom#option('auto_complete_delay', 20)
silent call deoplete#custom#option('auto_refresh_delay', 200)
call deoplete#enable_logging('WARN', g:vimrc_platform.temp . '/deoplete.log')
" call deoplete#custom#option('sources', { '_': ['LanguageClient'] })
call deoplete#custom#option('sources', { '_': [] })

set formatexpr=LanguageClient_textDocument_rangeFormatting()

imap <NUL> <C-space>
if has('nvim') && has('win32')
  " Neovim is missing a couple mappings on Windows.
  imap <M-c> <C-space>
endif

inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"

inoremap <expr> <C-space> deoplete#mappings#manual_complete()
inoremap <expr> <C-h> deoplete#smart_close_popup()."\<C-h>"
inoremap <expr> <BS> deoplete#smart_close_popup()."\<C-h>"
inoremap <expr> <C-g> deoplete#undo_completion()
inoremap <expr> <C-l> deoplete#refresh()
inoremap <expr> <M-space> deoplete#complete_common_string()

nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
nnoremap <silent> gi :call LanguageClient#textDocument_implementation()<CR>
nnoremap <silent> gr :call LanguageClient#textDocument_references()<CR>
nnoremap <silent> gs :call LanguageClient#textDocument_documentSymbol()<CR>
nnoremap <silent> <F2> :call LanguageClient#textDocument_rename()<CR>
nnoremap <silent> <C-s> :call LanguageClient#textDocument_signatureHelp()<CR>
imap <silent> <C-s> <C-o><C-s>

function! g:Multiple_cursors_before()
  call deoplete#custom#buffer_option('auto_complete', v:false)
endfunction
function! g:Multiple_cursors_after()
  call deoplete#custom#buffer_option('auto_complete', v:true)
endfunction

noremap <M-h> <C-w>8>
noremap <M-j> <C-w>8-
noremap <M-k> <C-w>8+
noremap <M-l> <C-w>8<
imap <M-h> <C-o><M-h>
imap <M-j> <C-o><M-j>
imap <M-k> <C-o><M-k>
imap <M-l> <C-o><M-l>
nnoremap <M-H> <C-w>H
nnoremap <M-J> <C-w>J
nnoremap <M-K> <C-w>K
nnoremap <M-L> <C-w>L

nnoremap <silent> <leader>T :bp<CR>
nnoremap <silent> <leader>t :bn<CR>
nnoremap <silent> <leader>p :b#<CR>
nnoremap <silent> <leader>q :b#<Bar>bd#<CR>
nnoremap <silent> <leader>Q :b#<Bar>bd!#<CR>
nnoremap <silent> <leader>n :echo fnamemodify(expand("%"), ":~:.")<CR>
" nnoremap <silent> <leader>h :A<CR>
nnoremap <silent> <leader>l :noh<CR>
nnoremap <leader>: :AsyncRun<space>
vnoremap <leader>: :AsyncRun<space>
nnoremap <silent> <leader>b :NERDTreeToggle<CR>
nnoremap <silent> <leader>P
      \ :if &paste <Bar> set nopaste <Bar>
      \ else <Bar> set paste <Bar> endif<CR>

nmap <leader><Tab><Tab> <S-Tab><S-Tab>

nnoremap <silent> <Tab><Tab> :tabnext<CR>
nnoremap <silent> <S-Tab><S-Tab> :tabprevious<CR>
nnoremap <silent> <Tab>N :tabnew<CR>
nnoremap <silent> <Tab>E :tabedit %<CR>
nnoremap <silent> <Tab>Q :tabclose<CR>
nnoremap <silent> <Tab>H :-tabmove<CR>
nnoremap <silent> <Tab>L :+tabmove<CR>
nnoremap <silent> <Tab>0 :tabfirst<CR>
nnoremap <silent> <Tab>- :tablast<CR>

augroup AutoCommands
  autocmd!

  autocmd VimEnter * call deoplete#initialize()

  autocmd FileType cpp set commentstring=//%s

  autocmd StdinReadPre * let s:std_in=1
  autocmd VimEnter *
    \ if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") |
    \ exe 'NERDTree' argv()[0] | wincmd p | ene | endif
  autocmd BufEnter *
    \ if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) |
    \ q | endif

  autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | silent! pclose | endif
augroup END

noremap! <Char-0x7F> <BS>
if exists('&cryptmethod')
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
