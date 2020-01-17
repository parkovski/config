set nocompatible
set autoindent
set title hidden
set tabstop=2 softtabstop=2 shiftwidth=2 expandtab
set backspace=indent,eol,start
set noerrorbells visualbell t_vb= belloff=all
set incsearch hlsearch
set ignorecase smartcase
set number relativenumber signcolumn=yes
set colorcolumn=81,101,121
set cursorline
set showcmd noshowmode showtabline=2
set splitright splitbelow
set wildmenu wildmode=longest:full,full
set complete=.
set laststatus=2
set nobackup nowritebackup noswapfile backupdir-=.
set foldmethod=marker nofoldenable foldcolumn=1
set autoread
set encoding=utf8 fileformats=unix,dos
set mouse=a

set t_Co=256
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

let mapleader="\<space>"

if has('win32')
  " AAAAAAGGGGGHHHHH
  nmap <C-z> <Nop>
endif

if !empty($VIMTERM)
  let &term=$VIMTERM
endif

if exists('+pyxversion')
  set pyxversion=3
endif

let g:vimrc_platform = {}

function! g:Chsh(shell)
  let &shell=a:shell
  if a:shell =~? 'pwsh\(\.exe\)\?' || a:shell =~? 'powershell\(\.exe\)\?'
    " TODO: Quoting doesn't work right here.
    set shellquote= shellxquote= shellredir=*> shellpipe=\|\ tee
    let &shellcmdflag = "-NoLogo -NonInteractive -NoProfile -Command"
  elseif a:shell =~? 'cmd\(\.exe\)\?'
    set shellquote= shellxquote=\" shellredir=>%s\ 2>&1 shellpipe=>
    let &shellxescape="\"&|<>()@^"
    let &shellcmdflag="/s /c"
  else
    set shellquote= shellxquote= shellpipe=\|\ tee shellredir=>%s\ 2>&1
    set shellcmdflag=-c
    if has('win32') && exists('+shellslash')
      set shellslash
    endif
  endif
endfunction
command! -bar -nargs=1 Chsh call Chsh(<q-args>)

function! g:Shellify(str)
  if &shell =~? 'pwsh' || &shell =~? 'powershell'
    return '"' . substitute(a:str, "[\"`]", "`\1", "g") . '"'
  elseif &shell =~? 'cmd'
    " TODO: Is this right?
    return '"' . substitute(a:str, "[\"]", "\"\"", "g") . '"'
  else
    return shellescape(a:str)
  endif
endfunction

if has('win32')
  Chsh pwsh.exe

  let g:vimrc_platform.dotvim = glob('~/vimfiles')
  let g:vimrc_platform.temp = $TEMP
  let g:vimrc_platform.lcinstall = 'powershell -nologo -nop -noni -file install.ps1'
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
      let &pythonthreedll=glob(s:pythonthreehome . "\\python3?.dll")
    endif
  endif

else " not win32
  let g:vimrc_platform.dotvim = glob('~/.vim')
  let g:vimrc_platform.temp = '/tmp'
  let g:vimrc_platform.lcinstall = 'bash install.sh'

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
  source g:vimrc_platform.dotvim . '/autoload/plug.vim'
  augroup InstallPlugins
    autocmd!
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  augroup END
endif

if empty($VIM_LANGCLIENT)
  let $VIM_LANGCLIENT = 'lcn'
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
endif

" Autocomplete popups
if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif
" Vimscript autocomplete
Plug 'Shougo/neco-vim'
Plug 'Shougo/echodoc.vim'
Plug 'junegunn/fzf.vim'

Plug 'terryma/vim-multiple-cursors'
Plug 'embear/vim-localvimrc'
" Symbol browser
Plug 'liuchengxu/vista.vim'
Plug 'itchyny/lightline.vim'
Plug 'mgee/lightline-bufferline'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'luochen1990/rainbow'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-abolish'
Plug 'bronson/vim-visual-star-search'
" Plug 'skywind3000/asyncrun.vim'
Plug 'scrooloose/nerdtree'
Plug 'sgur/vim-editorconfig'
" Plug 'michaeljsmith/vim-indent-object'
Plug 'nathanaelkane/vim-indent-guides'

" Color schemes
Plug 'sonph/onehalf', {'rtp': 'vim/'}
Plug 'bluz71/vim-moonfly-colors'
Plug 'cocopon/iceberg.vim'
Plug 'chase/focuspoint-vim'
Plug 'nightsense/snow'
Plug 'rakr/vim-two-firewatch'
Plug 'sainnhe/vim-color-desert-night'

" Syntaxes
" let g:polyglot_disabled = ['javascript', 'jsx', 'typescript', 'tsx']
Plug 'sheerun/vim-polyglot'
" Plug 'leafgarland/typescript-vim'
" Plug 'Quramy/vim-js-pretty-template'
" Plug 'jason0x43/vim-js-indent'
" Plug 'Quramy/tsuquyomi'

let g:lightline = {
      \ 'colorscheme': 'moonfly',
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
  call lightline#update()
  " execute tabpagenr().'tabn'
  " Redraw??
endfunction
command! -nargs=1 TabName call SetLightlineTabName(<q-args>)
command! -nargs=1 LightlineColors let g:lightline.colorscheme = <q-args> <bar> call lightline#enable()

function! MakeSession()
  if empty(g:lightline#tab#names)
    return
  endif

  if &shell =~? "pwsh"
    exe "silent !Out-File -Append -NoNewLine -InputObject " .
          \ Shellify("let g:lightline\\#tab\\#names = "
          \          . string(g:lightline#tab#names))
          \ . " " . Shellify(v:this_session)
  elseif &shell =~? "cmd"
    echo 'not supported'
  else
    exe "silent !echo -n " .
          \ Shellify("let g:lightline\\#tab\\#names = "
          \          . string(g:lightline#tab#names))
          \ . " " . Shellify(v:this_session)
  endif
endfunction

" TODO: Get PowerShell to not send \r\n here.
set sessionoptions=blank,buffers,curdir,help,winsize,tabpages,slash,unix
command! -bang -bar -nargs=? Session mksession<bang> <args> | call MakeSession()

let g:lightline#bufferline#show_number = 1
let g:lightline#bufferline#unnamed = '[No Name]'

let g:rainbow_active = 1

let g:deoplete#enable_at_startup = 1
let g:echodoc#enable_at_startup = 1
let g:echodoc#type = "floating"

let g:indent_guides_auto_colors = 0
let g:indent_guides_guide_size = 1
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_start_level = 2

hi link IndentGuidesOdd CursorLine
hi link IndentGuidesEven CursorLine
hi link ColorColumn CursorLine
hi link EchoDocFloat Pmenu

let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_concepts_highlight = 1

let g:LanguageClient_serverCommands = {
      \ 'cpp': ['clangd'],
      \ 'c': ['clangd'],
      \ 'rust': ['rls'],
      \ 'javascript': ['javascript-typescript-stdio'],
      \ 'typescript': ['javascript-typescript-stdio'],
      \ 'typescriptreact': ['javascript-typescript-stdio'],
      \ 'lua': ['lua-lsp'],
      \ }

if has('win32')
  let g:LanguageClient_serverCommands.javascript[0] .= '.cmd'
  let g:LanguageClient_serverCommands.typescript[0] .= '.cmd'
  let g:LanguageClient_serverCommands.typescriptreact[0] .= '.cmd'
endif

let g:LanguageClient_rootMarkers = {
      \ 'typescript': ['tsconfig.json'],
      \ 'javascript': ['package.json'],
      \ 'cpp': ['compile_commands.json', 'build/CMakeCache.txt'],
      \ 'rust': ['Cargo.toml'],
      \ }

let g:ale_fixers = {
      \ '*': ['remove_trailing_lines', 'trim_whitespace']
      \ }

let g:ale_linters = {
      \ 'c': ['clangd'],
      \ 'cpp': ['clangd'],
      \ 'rust': ['rls'],
      \ 'javascript': ['javascript-typescript-stdio'],
      \ 'typescript': ['javascript-typescript-stdio'],
      \ }

let g:ale#util#info_priority = 6

let g:LanguageClient_autoStart = 1
let g:LanguageClient_loadSettings = 1
let g:LanguageClient_settingsPath = g:vimrc_platform.dotvim . '/settings.json'
let g:LanguageClient_loggingFile = g:vimrc_platform.temp . '/lc-neovim.log'
let g:LanguageClient_loggingLevel = 'WARN'
let g:LanguageClient_serverStderr = g:vimrc_platform.temp . '/lc-server-err.log'
" let g:LanguageClient_waitOutputTimeout = 5

call plug#end()

if exists('*deoplete#custom#option')
  silent call deoplete#custom#option({ 'auto_complete_delay': 50,
                                     \ 'auto_refresh_delay': 200,
                                     \ 'min_pattern_length': 3,
                                     \ 'sources': { '_': s:sources } })

  " silent call deoplete#custom#source('_', 'converters',
  "                                  \ ['converter_remove_overlap',
  "                                  \   'converter_truncate_abbr'])
  silent call deoplete#enable_logging('WARNING', g:vimrc_platform.temp . '/deoplete.log')
endif

" set formatexpr=LanguageClient_textDocument_rangeFormatting()

imap <NUL> <C-space>
" Neovim is missing a couple mappings on Windows.
imap <C-_><Space> <C-space>
nmap <C-_><Tab> <S-Tab>
nmap <leader><C-_><Tab> <leader><S-Tab>

function! AutoCompleteSelect()
  if empty(v:completed_item)
    if pumvisible()
      return "\<C-e>\<CR>"
    endif
    return "\<CR>"
  endif

  if !pumvisible()
    return "\<CR>"
  endif

  return "\<C-y>"
endfunction

function! AutoCompleteJumpForwards()
  if pumvisible()
    return "\<C-n>"
  endif

  return "\<Tab>"
endfunction

function! AutoCompleteJumpBackwards()
  if pumvisible()
    return "\<C-p>"
  endif

  return "\<S-Tab>"
endfunction

function! AutoCompleteCancel()
  if pumvisible()
    if empty(v:completed_item)
      return "\<C-e>\<Esc>"
    endif
    return "\<Esc>"
  endif
  return "\<Esc>"
endfunction

inoremap <silent> <Tab> <C-r>=AutoCompleteJumpForwards()<CR>
snoremap <silent> <Tab> <Esc>:call AutoCompleteJumpForwards()<CR>
inoremap <silent> <S-Tab> <C-r>=AutoCompleteJumpBackwards()<CR>
snoremap <silent> <S-Tab> <Esc>:call AutoCompleteJumpBackwards()<CR>
inoremap <silent> <CR> <C-r>=AutoCompleteSelect()<CR>
inoremap <expr> <Esc> AutoCompleteCancel()
inoremap <expr> <C-d> pumvisible() ? "\<PageDown>" : "\<C-d>"
inoremap <expr> <C-u> pumvisible() ? "\<PageUp>" : "\<C-u>"

if exists('*deoplete#custom#option')
  function! g:Multiple_cursors_before()
    call deoplete#custom#buffer_option('auto_complete', v:false)
  endfunction
  function! g:Multiple_cursors_after()
    call deoplete#custom#buffer_option('auto_complete', v:true)
  endfunction

  nnoremap <silent> <C-Space> :call deoplete#auto_complete()<CR>
  inoremap <silent> <C-space> <C-o>:call deoplete#auto_complete()<CR>
  inoremap <expr> <C-h> deoplete#smart_close_popup()."\<C-h>"
  inoremap <expr> <BS> deoplete#smart_close_popup()."\<C-h>"
  inoremap <silent> <C-g> <C-o>:call deoplete#undo_completion()<CR>
  inoremap <expr> <C-l> pumvisible() ? deoplete#refresh() : "\<C-l>"
  nnoremap <silent> <M-Space> :call deoplete#complete_common_string()<CR>
  inoremap <silent> <M-Space> <C-o>:call deoplete#complete_common_string()<CR>
endif

if $VIM_LANGCLIENT ==? 'ale'
  nnoremap K :ALEHover<CR>
  nnoremap gd :ALEGoToDefinition<CR>
  nnoremap gD :ALEDocumentation<CR>
  nnoremap gr :ALEFindReferences<CR>
  nnoremap gs :ALESymbolSearch<Space>
  nnoremap gt :ALEGoToTypeDefinition<CR>
  " inoremap <C-space> <C-\><C-o>:ALEComplete<CR>
elseif $VIM_LANGCLIENT ==? 'lcn'
  nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
  nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
  nnoremap <silent> gi :call LanguageClient#textDocument_implementation()<CR>
  nnoremap <silent> gr :call LanguageClient#textDocument_references()<CR>
  nnoremap <silent> gs :call LanguageClient#textDocument_documentSymbol()<CR>
  nnoremap <silent> <F2> :call LanguageClient#textDocument_rename()<CR>
  nnoremap <silent> <C-s> :call LanguageClient#textDocument_signatureHelp()<CR>
  imap <silent> <C-s> <C-o><C-s>
endif

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

" Statement
"map (
"map )

" Block
"map {
"map }

" Inner indent up/down
"map []
"map ][

" Outer indent up/down
"map [[
"map ]]

" Top level block that there is more than one of
" E.g. C# class, cpp function.
"map [{
"map ]}

" Should do? g[, g], g{, g}

function! Align(col, start, end)
  for line in range(a:start, a:end)
    let l:curcol = col('.')
    if a:col < l:curcol
      exe l:line.'normal 0'.(l:curcol-1).'l'.(l:curcol - a:col).'X'
    elseif a:col > l:curcol
      exe l:line.'normal 0'.(l:curcol-1).'l'.(a:col - l:curcol).'i '
    endif
  endfor
endfunction

command! -bar -range -nargs=1 Align call Align(<args>, <line1>, <line2>)

" Keep the last thing copied when we paste.
xnoremap <expr> p 'pgv"'.v:register.'y'

nnoremap <silent> <leader>T :<C-U><C-R>=v:count<CR>bp<CR>
nnoremap <silent> <leader>t :<C-U><C-R>=v:count<CR>bn<CR>
nnoremap <silent> <leader>= :<C-U><C-R>=v:count<CR>b<CR>
nnoremap <silent> <leader>p :b#<CR>
nnoremap <silent> <leader>q :b#<Bar>bd#<CR>
nnoremap <silent> <leader>q! :b#<Bar>bd!#<CR>
nnoremap <silent> <leader>n :echo fnamemodify(expand("%"), ":~:.")<CR>
" nnoremap <silent> <leader>h :A<CR>
nnoremap <silent> <leader>l :noh<CR>
" nnoremap <leader>: :AsyncRun<space>
" vnoremap <leader>: :AsyncRun<space>
nnoremap <silent> <leader>b :NERDTreeToggle<CR>
nnoremap <silent> <leader>v :Vista!!<CR>
nnoremap <silent> <leader>P :set paste<CR>"+p:set nopaste<CR>
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

for nr in range(1, 9)
  exe 'nnoremap <silent> <leader>' . nr . ' :b' . nr . '<CR>'
endfor
nnoremap <silent> <leader>0 :b10<CR>

function! TryToFixColorScheme(colors)
  if empty(a:colors)
    let l:colors = g:colors_name
  else
    let l:colors = a:colors
  endif
  let l:fn = glob('~/shared/etc/fix-' . l:colors . '.vim')
  if filereadable(fn)
    exe 'source ' . l:fn
  endif
endf

augroup VimrcAutoCommands
  autocmd!

  if (has('win32') && has('nvim') && !empty(exepath($GH . "/conutils/isvt.exe")))
    " Fix some nvim glitches
    command! Conflags exe "!".
          \ $GH."/conutils/isvt.exe -p".
          \ " $([System.Diagnostics.Process]::GetCurrentProcess().Parent.Id)"
    autocmd VimEnter * exe "silent !".
          \ $GH."/conutils/isvt.exe -p".
          \ " $([System.Diagnostics.Process]::GetCurrentProcess().Parent.Id)".
          \ " o=_+DISABLE_NEWLINE_AUTO_RETURN"
  endif

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

  autocmd ColorScheme * call TryToFixColorScheme('')
augroup END

noremap! <Char-0x7F> <BS>
if exists('&cryptmethod')
  set cryptmethod=blowfish2
endif

set termguicolors
let g:colors = []
silent! let g:colors = readfile(glob('~/local/etc/vimcolor'))
if len(g:colors) > 0
  if len(g:colors) > 1
    let &background=g:colors[1]
  endif
  exe 'silent! colorscheme ' . g:colors[0]
  call TryToFixColorScheme(g:colors[0])
endif

" TODO: Move
" hi ColorColumn guibg=#203040
" hi MatchParen guibg=#204090 guifg=#a7bd9a

if exists('&t_SI') && !has('win32')
  let &t_SI = "\<Esc>[5 q"
  let &t_SR = "\<Esc>[3 q"
  let &t_EI = "\<Esc>[1 q"
endif
