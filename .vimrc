" TODO: if current script filename is in current dir, exit

" if has('win32')
"   set rtp ^=$HOME\vimfiles
" endif

set nocompatible
" set exrc secure
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
set complete=.
set pumheight=20
set laststatus=2
set nobackup nowritebackup noswapfile backupdir-=.
set foldmethod=marker nofoldenable
set autoread
set encoding=utf8 fileformats=unix,dos
set t_Co=256
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

let mapleader="\<space>"

if !empty($VIMTERM)
  let &term=$VIMTERM
endif

if exists('+pyxversion')
  set pyxversion=3
endif

let g:vimrc_platform = {}

function! g:Chsh(shell)
  let &shell=a:shell
  let l:shellslash = 0
  if a:shell =~? 'pwsh\(\.exe\)\?' || a:shell =~? 'powershell\(\.exe\)\?'
    " TODO: Quoting doesn't work right here.
    set shellquote= shellxquote= shellredir=*>
    let &shellpipe="| tee"
    set shellxescape=
    let &shellcmdflag = "-NoLogo -NonInteractive -NoProfile -Command"
    let l:shellslash = 1
  elseif a:shell =~? 'cmd\(\.exe\)\?'
    set shellquote= shellxquote=\" shellredir=>%s\ 2>&1 shellpipe=>
    "let &shellxescape='"&|<>>()@^'
    let &shellcmdflag="/s /c"
  else
    set shellquote= shellxquote= shellpipe=\| shellredir=">%s 2>&1"
    set shellcmdflag=-c
  endif
  if exists('+shellslash')
    let &shellslash = l:shellslash
  endif
endfunction
command! -bar -nargs=1 Chsh call Chsh(<q-args>)

if has('win32')
  Chsh pwsh.exe
  function! g:Shellify(str)
    return '"' . substitute(a:str, "[\"`]", "`\1", "g") . '"'
  endfunction

  let g:vimrc_platform.dotvim = glob('~/vimfiles')
  let g:vimrc_platform.temp = $TEMP
  let g:vimrc_platform.lcinstall = 'powershell install.ps1'
  if !empty($CQUERY_HOME)
    let g:vimrc_platform.cquery_exe = $CQUERY_HOME . '/bin/cquery.exe'
  else
    let g:vimrc_platform.cquery_exe = exepath('cquery.exe')
  endif

  let s:pythonthreehome = ''
  if !empty($PYTHON3HOME)
    let s:pythonthreehome = $PYTHON3HOME
  elseif !empty($PYTHON3DLL)
    let s:pythonthreehome=fnamemodify($PYTHON3DLL, ':p:h')
  endif

  let g:python3_host_prog=s:pythonthreehome . "\\python3.exe"
  if !filereadable(g:python3_host_prog)
    let g:python3_host_prog=s:pythonthreehome . "\\python.exe"
  endif

  if exists('&pythonthreehome')
    let &pythonthreehome = s:pythonthreehome
  endif

  if exists('&pythonthreedll')
    if !empty($PYTHON3DLL)
      let &pythonthreedll=$PYTHON3DLL
    else
      let &pythonthreedll=s:pythonthreehome . "\\python37.dll"
    endif
  endif

else " not win32
  function! g:Shellify(str)
    return shellescape(a:str)
  endfunction

  let g:vimrc_platform.dotvim = glob('~/.vim')
  let g:vimrc_platform.temp = '/tmp'
  let g:vimrc_platform.lcinstall = 'bash install.sh'
  if !empty($CQUERY_HOME)
    let g:vimrc_platform.cquery_exe = $CQUERY_HOME . '/bin/cquery'
    " Allow Windows cquery by setting CQUERY_HOME in WSL.
    if $IS_WSL && !exepath(g:vimrc_platform.cquery_exe)
      if exepath($CQUERY_HOME . '/bin/cquery.exe')
        let g:vimrc_platform.cquery_exe = $CQUERY_HOME . '/bin/cquery.exe'
      endif
    endif
  else
    let g:vimrc_platform.cquery_exe = exepath('cquery')
  endif

  if $IS_WSL && exepath('win32yank.exe')
    let g:clipboard = {
          \   'name': 'win32yank',
          \   'copy': {
          \     '+': 'win32yank.exe -i',
          \     '*': 'win32yank.exe -i',
          \   },
          \   'paste': {
          \     '+': 'win32yank.exe -o',
          \     '*': 'win32yank.exe -o',
          \   },
          \   'cache_enabled': 1,
          \ }
  endif
endif

if !filereadable(g:vimrc_platform.dotvim . '/autoload/plug.vim')
  exe 'silent !curl -fLo ' . g:vimrc_platform.dotvim . '/autoload/plug.vim ' .
    \ '--create-dirs ' .
    \ 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  augroup InstallPlugins
    autocmd!
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  augroup END
endif

call plug#begin(g:vimrc_platform.dotvim . '/bundle')

Plug 'autozimu/LanguageClient-neovim', {
  \ 'branch': 'next',
  \ 'do': g:vimrc_platform.lcinstall,
  \ }

Plug 'itchyny/lightline.vim'
Plug 'mgee/lightline-bufferline'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'luochen1990/rainbow'
Plug 'tpope/vim-fugitive'
Plug 'bronson/vim-visual-star-search'
Plug 'skywind3000/asyncrun.vim'
Plug 'terryma/vim-multiple-cursors'
Plug 'scrooloose/nerdtree'
Plug 'sgur/vim-editorconfig'
Plug 'Shougo/echodoc.vim'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

Plug 'PProvost/vim-ps1'
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'plasticboy/vim-markdown'
Plug 'stephpy/vim-yaml'
Plug 'cespare/vim-toml'
Plug 'elzr/vim-json'
Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
Plug 'Quramy/tsuquyomi'
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
      \ 'component_type': {'buffers': 'tabsel'},
      \ 'inactive': {
      \   'left': [['filename', 'modified']],
      \   'right': [['lineinfo'], ['percent']] },
      \ 'tab': {
      \   'active': ['tabnum', 'name'],
      \   'inactive': ['tabnum', 'name'] },
      \ }

let g:lightline.tab_component_function = {
      \ 'tabnum': 'lightline#tab#tabnum',
      \ 'name': 'LightlineTabName' }

if !exists('g:lightline#tab#names')
  let g:lightline#tab#names = {}
endif
function! LightlineTabName(tabnum)
  if has_key(g:lightline#tab#names, a:tabnum)
    return g:lightline#tab#names[a:tabnum]
  endif
  return lightline#tab#filename(tabpagenr())
endfunction
" au TabClosed...
function! SetLightlineTabName(cargs)
  let l:args = split(a:cargs, '^[0-9]\+\zs')
  if len(l:args) == 1
    let l:num = tabpagenr()
    let l:name = l:args[0]
  else
    let l:num = l:args[0]
    let l:name = substitute(l:args[1], '^\W\+', '', '')
  endif
  let g:lightline#tab#names[l:num] = l:name
  " execute tabpagenr().'tabn'
  " Redraw??
endfunction
command! -nargs=1 TabName call SetLightlineTabName(<q-args>)

" TODO: Get PowerShell to not send \r\n here.
set sessionoptions=blank,buffers,curdir,help,winsize,tabpages,slash,unix
command! -bang -bar -nargs=? Session
  \ mksession<bang> <args> |
  \ if !empty(g:lightline#tab#names) |
  \   exe "silent !echo " .
  \     Shellify("let g:lightline\\#tab\\#names = " .
  \              string(g:lightline#tab#names)) .
  \     " >> " . Shellify(v:this_session) |
  \ endif

let g:lightline#bufferline#show_number = 1
let g:lightline#bufferline#unnamed = '[No Name]'

let g:rainbow_active = 1

" let g:cmake_install_prefix = $CMAKE_INSTALL_PREFIX
" let g:cmake_project_generator = 'Ninja'
" let g:cmake_export_compile_commands = 1

let g:deoplete#enable_at_startup = 1
let g:echodoc#enable_at_startup = 1

let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_concepts_highlight = 1

let g:LanguageClient_serverCommands = {
      \ 'cpp': ['clangd'],
      \ 'c': ['clangd'],
      \ 'javascript': ['javascript-typescript-stdio'],
      \ 'typescript': ['javascript-typescript-stdio'],
      \ 'lua': ['lua-lsp'],
      \ }

      " \ 'cpp': [g:vimrc_platform.cquery_exe,
      " \         '--log-file=' . g:vimrc_platform.temp . '/cquery.log'],
      " \ 'c': [g:vimrc_platform.cquery_exe,
      " \       '--log-file=' . g:vimrc_platform.temp . '/cquery.log'],

let g:LanguageClient_autoStart = 1
let g:LanguageClient_loadSettings = 1
let g:LanguageClient_settingsPath = g:vimrc_platform.dotvim . '/settings.json'
let g:LanguageClient_loggingFile = g:vimrc_platform.temp . '/lc-neovim.log'
let g:LanguageClient_loggingLevel = 'WARN'
let g:LanguageClient_serverStderr = g:vimrc_platform.temp . '/lc-server-err.log'
" let g:LanguageClient_waitOutputTimeout = 5

" These can't be disabled so I guess just set them to something I'll never type,
" since deoplete will handle this stuff anyways.
let g:UltiSnipsExpandTrigger = '<C-^>X'
let g:UltiSnipsJumpForwardTrigger = '<C-^>F'
let g:UltiSnipsJumpBackwardTrigger = "<C-^>B"
let g:UltiSnipsListSnippets = "<C-^>L"

call plug#end()

silent call deoplete#custom#option({ 'auto_complete_delay': 50,
                                   \ 'auto_refresh_delay': 200,
                                   \ 'min_pattern_length': 3,
                                   \ 'sources': { '_': [] } })
silent call deoplete#custom#source('_', 'converters',
                                 \ ['converter_remove_overlap',
                                 \   'converter_truncate_abbr'])
silent call deoplete#enable_logging('WARN', g:vimrc_platform.temp . '/deoplete.log')

set formatexpr=LanguageClient_textDocument_rangeFormatting()

imap <NUL> <C-space>
" Neovim is missing a couple mappings on Windows.
imap <M-x> <C-space>
nmap <M-w> <S-Tab>
nmap <leader><M-w> <leader><S-Tab>

function! ExpandLspSnippet()
  let l:value = v:completed_item.word
  let l:matched = len(l:value)
  if l:matched <= 0
    return ''
  endif

  " remove inserted chars before expand snippet
  if col('.') == col('$')
    let l:matched -= 1
    exec 'normal! ' . l:matched . 'Xx'
  else
    exec 'normal! ' . l:matched . 'X'
  endif

  if col('.') == col('$') - 1
    " move to $ if at the end of line.
    call cursor(line('.'), col('$'))
  endif

  " expand snippet now.
  return UltiSnips#Anon(l:value)
endfunction

let g:ulti_expand_res = 0
function! AutoCompleteSelect()
  if !pumvisible()
    return "\<CR>"
  endif

  if v:completed_item.kind ==# 'Snippet'
    return ExpandLspSnippet()
  endif

  call UltiSnips#ExpandSnippet()
  if g:ulti_expand_res
    return ""
  endif

  return "\<C-y>"
endfunction

let g:ulti_jump_forwards_res = 0
function! AutoCompleteJumpForwards()
  if pumvisible()
    return "\<C-n>"
  endif

  call UltiSnips#JumpForwards()
  if g:ulti_jump_forwards_res
    return ""
  endif

  return "\<Tab>"
endfunction

let g:ulti_jump_backwards_res = 0
function! AutoCompleteJumpBackwards()
  if pumvisible()
    return "\<C-p>"
  endif

  call UltiSnips#JumpBackwards()
  if g:ulti_jump_backwards_res
    return ""
  endif

  return "\<S-Tab>"
endfunction

inoremap <silent> <Tab> <C-r>=AutoCompleteJumpForwards()<CR>
snoremap <silent> <Tab> <Esc>:call AutoCompleteJumpForwards()<CR>
inoremap <silent> <S-Tab> <C-r>=AutoCompleteJumpBackwards()<CR>
snoremap <silent> <S-Tab> <Esc>:call AutoCompleteJumpBackwards()<CR>
inoremap <silent> <CR> <C-r>=AutoCompleteSelect()<CR>
inoremap <expr> <C-d> pumvisible() ? "\<PageDown>" : "\<C-d>"
inoremap <expr> <C-u> pumvisible() ? "\<PageUp>" : "\<C-u>"

inoremap <expr> <C-space> deoplete#mappings#manual_complete()
inoremap <expr> <C-h> deoplete#smart_close_popup()."\<C-h>"
inoremap <expr> <BS> deoplete#smart_close_popup()."\<C-h>"
inoremap <expr> <C-g> deoplete#undo_completion()
inoremap <expr> <C-l> pumvisible() ? deoplete#refresh() : "\<C-l>"
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

nnoremap <M->> <C-w>8>
nnoremap <M--> <C-w>8-
nnoremap <M-+> <C-w>8+
nmap <M-=> <M-+>
nnoremap <M-lt> <C-w>8<
nnoremap <M-H> <C-w>H
nnoremap <M-J> <C-w>J
nnoremap <M-K> <C-w>K
nnoremap <M-L> <C-w>L

noremap! <M-h> <Left>
noremap! <M-j> <Down>
noremap! <M-k> <Up>
noremap! <M-l> <Right>
noremap! <M-b> <S-Left>
noremap! <M-e> <S-Right>
noremap! <C-a> <Home>
noremap! <C-e> <End>

nnoremap <silent> <leader>T :<C-U><C-R>=v:count<CR>bp<CR>
nnoremap <silent> <leader>t :<C-U><C-R>=v:count<CR>bn<CR>
nnoremap <silent> <leader>= :<C-U><C-R>=v:count<CR>b<CR>
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
nnoremap <silent> <leader>r :set relativenumber!<CR>

nnoremap <silent> <leader><Tab> :tabnext<CR>
nnoremap <silent> <leader><S-Tab> :tabprevious<CR>
nnoremap <silent> <leader>N :tabnew<CR>
nnoremap <silent> <leader>E :tabedit %<CR>
nnoremap <silent> <leader>Q :tabclose<CR>
nnoremap <silent> <leader>H :-tabmove<CR>
nnoremap <silent> <leader>L :+tabmove<CR>
nnoremap <silent> <leader>_ :tabfirst<CR>
nnoremap <silent> <leader>+ :tablast<CR>

for nr in [1, 2, 3, 4, 5, 6, 7, 8, 9]
  exe 'nnoremap <silent> <leader>' . nr . ' :b' . nr . '<CR>'
endfor
nnoremap <silent> <leader>0 :b10<CR>

augroup VimrcAutoCommands
  autocmd!

  autocmd VimEnter * silent call deoplete#initialize()

  autocmd FileType cpp set commentstring=//%s
  autocmd FileType cmake set commentstring=#%s

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
let g:colors = []
silent! let g:colors = readfile(glob('~/shared/etc/vimcolor'))
if len(g:colors) > 0
  if len(g:colors) > 1
    let &background=g:colors[1]
  endif
  exe 'colorscheme ' . g:colors[0]
endif

" TODO: Move
" hi ColorColumn guibg=#203040
" hi MatchParen guibg=#204090 guifg=#a7bd9a

if exists('&t_SI') && !has('win32')
  let &t_SI = "\<Esc>[5 q"
  let &t_SR = "\<Esc>[3 q"
  let &t_EI = "\<Esc>[1 q"
endif
