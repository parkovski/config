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
set foldmethod=marker nofoldenable foldcolumn=1
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
  if a:shell =~? 'pwsh\(\.exe\)\?' || a:shell =~? 'powershell\(\.exe\)\?'
    " TODO: Quoting doesn't work right here.
    set shellquote= shellxquote= shellredir=*> shellpipe=\|\ tee shellxescape=
    let &shellcmdflag = "-NoLogo -NonInteractive -NoProfile -Command"
  elseif a:shell =~? 'cmd\(\.exe\)\?'
    set shellquote= shellxquote=( shellredir=>%s\ 2>&1 shellpipe=>
    let &shellxescape='"&|<>()@^'
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

if $VIM_ALE
  let g:ale_completion_enabled = 1
  Plug 'w0rp/ale'
else
  if has('nvim')
    Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
  else
    Plug 'Shougo/deoplete.nvim'
    Plug 'roxma/nvim-yarp'
    Plug 'roxma/vim-hug-neovim-rpc'
  endif
  Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': g:vimrc_platform.lcinstall,
    \ }
  Plug 'terryma/vim-multiple-cursors'
  Plug 'Shougo/echodoc.vim'
  Plug 'SirVer/ultisnips'
  Plug 'honza/vim-snippets'
endif

Plug 'itchyny/lightline.vim'
Plug 'mgee/lightline-bufferline'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'luochen1990/rainbow'
Plug 'tpope/vim-fugitive'
Plug 'bronson/vim-visual-star-search'
" Plug 'skywind3000/asyncrun.vim'
Plug 'scrooloose/nerdtree'
Plug 'sgur/vim-editorconfig'
Plug 'michaeljsmith/vim-indent-object'
Plug 'nathanaelkane/vim-indent-guides'

Plug 'sonph/onehalf', {'rtp': 'vim/'}
Plug 'bluz71/vim-moonfly-colors'
Plug 'cocopon/iceberg.vim'
Plug 'chase/focuspoint-vim'
Plug 'nightsense/snow'
Plug 'rakr/vim-two-firewatch'

Plug 'PProvost/vim-ps1'
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'plasticboy/vim-markdown'
Plug 'stephpy/vim-yaml'
Plug 'cespare/vim-toml'
Plug 'elzr/vim-json'
Plug 'pangloss/vim-javascript'
Plug 'HerringtonDarkholme/yats'
if has('win32')
  Plug 'Quramy/tsuquyomi'
else
  Plug 'mhartington/nvim-typescript', {'build': './install.sh'}
endif
Plug 'Shougo/neco-vim'

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

" let g:cmake_install_prefix = $CMAKE_INSTALL_PREFIX
" let g:cmake_project_generator = 'Ninja'
" let g:cmake_export_compile_commands = 1

let g:deoplete#enable_at_startup = 1
let g:echodoc#enable_at_startup = 1

let g:indent_guides_auto_colors = 0
let g:indent_guides_guide_size = 1
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_start_level = 2

hi link IndentGuidesOdd CursorLine
hi link IndentGuidesEven CursorLine

let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_concepts_highlight = 1

let g:LanguageClient_serverCommands = {
      \ 'cpp': ['cquery'],
      \ 'c': ['cquery'],
      \ 'rust': ['rls'],
      \ 'javascript': ['javascript-typescript-stdio'],
      \ 'typescript': ['javascript-typescript-stdio'],
      \ 'lua': ['lua-lsp'],
      \ }

" let g:ale_fixers = {
"       \ '*': ['remove_trailing_lines', 'trim_whitespace']
"       \ }

" let g:ale_linters = {
"       \ 'c': ['cquery'],
"       \ 'cpp': ['cquery'],
"       \ 'rust': ['rls'],
"       \ 'javascript': ['javascript-typescript-stdio'],
"       \ }

if has('win32')
  call add(g:LanguageClient_serverCommands.cpp, '-fno-delayed-template-parsing')
endif
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

if exists('*deoplete#custom#option')
  silent call deoplete#custom#option({ 'auto_complete_delay': 50,
                                     \ 'auto_refresh_delay': 200,
                                     \ 'min_pattern_length': 3,
                                     \ 'sources': { '_': [] } })
  silent call deoplete#custom#source('_', 'converters',
                                   \ ['converter_remove_overlap',
                                   \   'converter_truncate_abbr'])
  silent call deoplete#enable_logging('WARNING', g:vimrc_platform.temp . '/deoplete.log')
endif

" set formatexpr=LanguageClient_textDocument_rangeFormatting()

imap <NUL> <C-space>
" Neovim is missing a couple mappings on Windows.
imap <M-x> <C-space>
nmap <M-w> <S-Tab>
nmap <leader><M-w> <leader><S-Tab>

function! ExpandLspSnippet()
  if empty(v:completed_item)
    return v:false
  endif
  let l:value = v:completed_item.word
  let l:matched = len(l:value)
  if l:matched <= 0
    return v:false
  endif
  if v:completed_item.menu !=? '[US] '
    return v:false
  endif

  " remove inserted chars before expand snippet
  if col('.') == col('$')
    exec 'normal! ' . (l:matched - 1) . 'Xx'
    call cursor(line('.'), col('$'))
    call UltiSnips#Anon(l:value)
  else
    exec 'normal! ' . l:matched . 'X'
    call UltiSnips#Anon(l:value)
  endif

  return v:true
endfunction

let g:ulti_expand_or_jump_res = 0
function! AutoCompleteSelect()
  if empty(v:completed_item)
    if pumvisible()
      return "\<C-e>\<CR>"
    endif
    return "\<CR>"
  endif

  call UltiSnips#ExpandSnippetOrJump()
  if g:ulti_expand_or_jump_res
    if pumvisible() | return "\<C-y>" | endif
    return ""
  endif

  if !pumvisible()
    return "\<CR>"
  endif

  " if ExpandLspSnippet()
  "   return "\<C-y>"
  " endif

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

function! AutoCompleteCancel()
  if pumvisible()
    if empty(v:completed_item)
      return "\<C-e>\<Esc>"
    endif
    return "\<Esc>"
  endif
  return "\<Esc>"
endfunction

function! DoTab()
  if pumvisible()
    return "\<C-n>"
  endif
  return "\<Tab>"
endfunction

function! DoShiftTab()
  if pumvisible()
    return "\<C-p>"
  endif
  return "\<S-Tab>"
endfunction

function! DoEnter()
  if pumvisible()
    return "\<C-y>"
  endif
  return "\<CR>"
endfunction

function! DoEsc()
  if pumvisible()
    return "\<C-e>"
  endif
  return "\<Esc>"
endfunction

if $VIM_ALE
  inoremap <silent> <Tab> <C-r>=DoTab()<CR>
  snoremap <silent> <Tab> <Esc>:call DoTab()<CR>
  inoremap <silent> <S-Tab> <C-r>=DoShiftTab()<CR>
  snoremap <silent> <S-Tab> <Esc>:call DoShiftTab()<CR>
  inoremap <silent> <CR> <C-r>=DoEnter()<CR>

  nnoremap <silent> K :ALEHover<CR>
  nnoremap <silent> gd :ALEGoToDefinition<CR>
  nnoremap <silent> gr :ALEFindReferences<CR>
  nnoremap <silent> gs :ALESymbolSearch<CR>
else
  inoremap <silent> <Tab> <C-r>=AutoCompleteJumpForwards()<CR>
  snoremap <silent> <Tab> <Esc>:call AutoCompleteJumpForwards()<CR>
  inoremap <silent> <S-Tab> <C-r>=AutoCompleteJumpBackwards()<CR>
  snoremap <silent> <S-Tab> <Esc>:call AutoCompleteJumpBackwards()<CR>
  inoremap <silent> <CR> <C-r>=AutoCompleteSelect()<CR>

  inoremap <expr> <C-space> deoplete#mappings#manual_complete()
  inoremap <expr> <C-h> deoplete#smart_close_popup()."\<C-h>"
  inoremap <expr> <BS> deoplete#smart_close_popup()."\<C-h>"
  inoremap <expr> <C-g> deoplete#undo_completion()
  inoremap <expr> <C-l> pumvisible() ? deoplete#refresh() : "\<C-l>"
  inoremap <expr> <M-space> deoplete#complete_common_string()
  inoremap <expr> <Esc> AutoCompleteCancel()

  nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
  nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
  nnoremap <silent> gi :call LanguageClient#textDocument_implementation()<CR>
  nnoremap <silent> gr :call LanguageClient#textDocument_references()<CR>
  nnoremap <silent> gs :call LanguageClient#textDocument_documentSymbol()<CR>
  nnoremap <silent> <F2> :call LanguageClient#textDocument_rename()<CR>
  nnoremap <silent> <C-s> :call LanguageClient#textDocument_signatureHelp()<CR>
  imap <silent> <C-s> <C-o><C-s>
endif

inoremap <expr> <C-d> pumvisible() ? "\<PageDown>" : "\<C-d>"
inoremap <expr> <C-u> pumvisible() ? "\<PageUp>" : "\<C-u>"

if exists('*deoplete#custom#buffer_option')
  function! g:Multiple_cursors_before()
    call deoplete#custom#buffer_option('auto_complete', v:false)
  endfunction
  function! g:Multiple_cursors_after()
    call deoplete#custom#buffer_option('auto_complete', v:true)
  endfunction
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
nnoremap <silent> <leader>P :set paste!<CR>
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

augroup VimrcAutoCommands
  autocmd!

  " autocmd VimEnter * silent call deoplete#initialize()

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
silent! let g:colors = readfile(glob('~/local/etc/vimcolor'))
if len(g:colors) > 0
  if len(g:colors) > 1
    let &background=g:colors[1]
  endif
  exe 'silent! colorscheme ' . g:colors[0]
endif

" TODO: Move
" hi ColorColumn guibg=#203040
" hi MatchParen guibg=#204090 guifg=#a7bd9a

if exists('&t_SI') && !has('win32')
  let &t_SI = "\<Esc>[5 q"
  let &t_SR = "\<Esc>[3 q"
  let &t_EI = "\<Esc>[1 q"
endif
