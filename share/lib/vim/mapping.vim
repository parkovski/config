noremap  <NUL> <C-Space>
noremap! <NUL> <C-Space>
noremap  <Char-0x7F> <BS>
noremap! <Char-0x7F> <BS>

tnoremap <C-a> <C-\><C-n>
tnoremap <C-a><C-a> <C-a>

function! s:CocPumVisible()
  return exists('*coc#pum#visible') && coc#pum#visible()
endfunction

function! s:AutoCompleteSelect()
  if exists('*coc#pum#visible')
    if coc#pum#visible()
      return coc#pum#confirm()
    "else
    "  return "\<C-g>u\<CR>\<C-r>=coc#on_enter()\<CR>"
    endif
  elseif pumvisible()
    if empty(v:completed_item)
      return "\<C-e>\<CR>"
    endif
    return "\<C-y>"
  endif

  return "\<CR>"
endfunction

function! s:AutoCompleteJumpForwards()
  if <SID>CocPumVisible()
    return coc#pum#next(1)
  elseif pumvisible()
    return "\<C-n>"
  endif

  return "\<Tab>"
endfunction

function! s:AutoCompleteJumpBackwards()
  if <SID>CocPumVisible()
    return coc#pum#prev(1)
  elseif pumvisible()
    return "\<C-p>"
  endif

  return "\<S-Tab>"
endfunction

function! s:AutoCompleteCancel()
  if <SID>CocPumVisible()
    call coc#pum#cancel()
  elseif pumvisible()
    if empty(v:completed_item)
      return "\<C-e>\<Esc>"
    endif
  endif

  return "\<Esc>"
endfunction

function! s:ScrollDown()
  if <SID>CocPumVisible()
    return coc#pum#scroll(1)
  elseif pumvisible()
    return "\<PageDown>"
  else
    return "\<C-d>"
  endif
endfunction

function! s:ScrollUp()
  if <SID>CocPumVisible()
    return coc#pum#scroll(0)
  elseif pumvisible()
    return "\<PageUp>"
  else
    return "\<C-u>"
  endif
endfunction

" inoremap <silent><expr> <Tab>   <SID>AutoCompleteJumpForwards()
" snoremap <silent><expr> <Tab>   <SID>AutoCompleteJumpForwards()
" inoremap <silent><expr> <S-Tab> <SID>AutoCompleteJumpBackwards()
" snoremap <silent><expr> <S-Tab> <SID>AutoCompleteJumpBackwards()
" inoremap <silent><expr> <CR>    <SID>AutoCompleteSelect()
" snoremap <silent><expr> <CR>    <SID>AutoCompleteSelect()
" inoremap <silent><expr> <Esc>   <SID>AutoCompleteCancel()
" snoremap <silent><expr> <Esc>   <SID>AutoCompleteCancel()
inoremap <silent><expr> <C-d>   <SID>ScrollDown()
snoremap <silent><expr> <C-d>   <SID>ScrollDown()
inoremap <silent><expr> <C-u>   <SID>ScrollUp()
snoremap <silent><expr> <C-u>   <SID>ScrollUp()

" if exists('*deoplete#custom#option')
"  function! g:Multiple_cursors_before()
"    call deoplete#custom#buffer_option('auto_complete', v:false)
"  endfunction
"  function! g:Multiple_cursors_after()
"    call deoplete#custom#buffer_option('auto_complete', v:true)
"  endfunction
"
"  nnoremap <silent> <C-Space> :call deoplete#auto_complete()<CR>
"  inoremap <silent> <C-space> <C-o>:call deoplete#auto_complete()<CR>
"  inoremap <silent> <expr> <C-h> deoplete#smart_close_popup()."\<C-h>"
"  inoremap <silent> <expr> <BS> deoplete#smart_close_popup()."\<C-h>"
"  inoremap <silent> <C-g> <C-o>:call deoplete#undo_completion()<CR>
"  inoremap <silent> <expr> <C-l> pumvisible() ? deoplete#refresh() : "\<C-l>"
"  nnoremap <silent> <M-Space> :call deoplete#complete_common_string()<CR>
"  inoremap <silent> <M-Space> <C-o>:call deoplete#complete_common_string()<CR>
" endif

" For nvim-lsp see lsp.lua.
if $VIM_LANGCLIENT ==? 'ale'
  nnoremap K <Cmd>ALEHover<CR>
  nnoremap gd <Cmd>ALEGoToDefinition<CR>
  nnoremap gD <Cmd>ALEDocumentation<CR>
  nnoremap gr <Cmd>ALEFindReferences<CR>
  nnoremap gs <Cmd>ALESymbolSearch<Space>
  nnoremap gt <Cmd>ALEGoToTypeDefinition<CR>
  inoremap <C-space> <Cmd>ALEComplete<CR>
elseif $VIM_LANGCLIENT ==? 'lcn'
  nnoremap <silent> K <Cmd>call LanguageClient#textDocument_hover()<CR>
  nnoremap <silent> gd <Cmd>call LanguageClient#textDocument_definition()<CR>
  nnoremap <silent> gi <Cmd>call LanguageClient#textDocument_implementation()<CR>
  nnoremap <silent> gr <Cmd>call LanguageClient#textDocument_references()<CR>
  nnoremap <silent> gs <Cmd>call LanguageClient#textDocument_documentSymbol()<CR>
  nnoremap <silent> <F2> <Cmd>call LanguageClient#textDocument_rename()<CR>
  nnoremap <silent> <C-s> <Cmd>call LanguageClient#textDocument_signatureHelp()<CR>
  imap <silent> <C-s> <C-o><C-s>
elseif $VIM_LANGCLIENT ==? 'coc'
  imap <silent><expr> <C-Space> coc#refresh()

  " GoTo code navigation.
  nmap <silent> gd <Plug>(coc-definition)
  xmap <silent> gd <Plug>(coc-definition)
  nmap <silent> gD <Plug>(coc-declaration)
  xmap <silent> gD <Plug>(coc-declaration)
  nmap <silent> gy <Plug>(coc-type-definition)
  xmap <silent> gy <Plug>(coc-type-definition)
  nmap <silent> gi <Plug>(coc-implementation)
  xmap <silent> gi <Plug>(coc-implementation)
  nmap <silent> gr <Plug>(coc-references)
  xmap <silent> gr <Plug>(coc-references)
  nmap <silent> gR <Plug>(coc-references-used)
  xmap <silent> gR <Plug>(coc-references-used)
  map  <silent> gh <Cmd>call CocActionAsync('showSignatureHelp')<CR>
  imap <silent> <C-s> <C-o>gh

  set formatexpr=<Plug>(coc-format-selected)
  map gQ <Plug>(coc-format)

  map  <silent> <M-f> <Plug>(coc-fix-current)
  imap <silent> <M-f> <Plug>(coc-fix-current)

  nmap <silent> <M-c> <Plug>(coc-codeaction-cursor)
  imap <silent> <M-c> <Plug>(coc-codeaction-cursor)
  vmap <silent> <M-c> <Plug>(coc-codeaction-selected)
  map  <silent> <M-C> <Plug>(coc-codeaction-line)
  imap <silent> <M-C> <Plug>(coc-codeaction-line)

  map  <silent> <M-d> <Plug>(coc-diagnostic-next)
  imap <silent> <M-d> <Plug>(coc-diagnostic-next)
  map  <silent> <M-D> <Plug>(coc-diagnostic-prev)
  imap <silent> <M-D> <Plug>(coc-diagnostic-prev)
  map  <silent> <M-e> <Plug>(coc-diagnostic-next-error)
  imap <silent> <M-e> <Plug>(coc-diagnostic-next-error)
  map  <silent> <M-E> <Plug>(coc-diagnostic-prev-error)
  imap <silent> <M-E> <Plug>(coc-diagnostic-prev-error)

  map  <silent> <F2> <Plug>(coc-rename)
  imap <silent> <F2> <Plug>(coc-rename)

  " Use K to show documentation in preview window.
  nnoremap K <Cmd>call <SID>show_documentation()<CR>

  function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
      execute 'h '.expand('<cword>')
    else
      call CocAction('doHover')
    endif
  endfunction
endif

map <M-w> <Cmd>lua require('spider').motion('w')<CR>
map <M-e> <Cmd>lua require('spider').motion('e')<CR>
map <M-b> <Cmd>lua require('spider').motion('b')<CR>

noremap <M-lt> <C-w>5<
map!    <M-lt> <C-o><M-lt>
noremap <M->> <C-w>5>
map!    <M->> <C-o><M->>
noremap <M-V> <C-w>5-
map!    <M-V> <C-o><M-V>
noremap <M-^> <C-w>5+
map!    <M-^> <C-o><M-^>

noremap! <M-BS> x
noremap! <M-h> <Left>
noremap! <M-j> <Down>
noremap! <M-k> <Up>
noremap! <M-l> <Right>
noremap! <M-b> <S-Left>
noremap! <M-w> <S-Right>
noremap! <C-a> <Home>
noremap! <C-e> <End>

" Insert a line above this one.
imap <C-J> O

" Swap with deleted text
xnoremap <C-s> <Esc>`.``gvP``P

" Make D/Y like C
nnoremap D d$
nnoremap Y y$

" Keep the last thing copied when we paste.
xnoremap <expr> P 'Pgv"'.v:register.'y'
xmap p Pg`]

" System clipboard
noremap  +     "+
noremap! <M-+> <C-r>+
map!     <M-=> <M-+>

" Paste while editing
noremap! <M-"> <C-r>"
map!     <M-'> <M-">

" Null clipboard
noremap  _    "_

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

function! Align(col, start, end) abort
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

nnoremap <expr> <leader>T "\<Cmd>".v:count."bp\<CR>"
nnoremap <expr> <leader>t "\<Cmd>".v:count."bn\<CR>"
nnoremap <leader>p <Cmd>b#<CR>
nnoremap <leader>q <Cmd>b#<Bar>bd#<CR>
nnoremap <leader>Q <Cmd>b#<Bar>bd!#<CR>
nnoremap <leader>n <Cmd>echo fnamemodify(expand("%"), ":~:.")<CR>
nnoremap <leader>l <Cmd>noh<CR>
nnoremap <leader>b <Cmd>NvimTreeToggle<CR>
nnoremap <leader>v <Cmd>Vista!!<CR>
nnoremap <leader>r <Cmd>set relativenumber!<CR>

nnoremap <leader><Tab> <Cmd>tabnext<CR>
nnoremap <leader><S-Tab> <Cmd>tabprevious<CR>
nnoremap <leader>N <Cmd>tabedit %<CR>
nnoremap <leader>X <Cmd>tabclose<CR>
nnoremap <leader>H <Cmd>-tabmove<CR>
nnoremap <leader>L <Cmd>+tabmove<CR>
nnoremap <leader>_ <Cmd>tabfirst<CR>
nnoremap <leader>+ <Cmd>tablast<CR>

function! s:FilterBuffer(nr)
  return bufexists(a:nr) && buflisted(a:nr) &&
        \ getbufvar(a:nr, "buftype") !=? "quickfix"
endfunction

function! s:GetBufferLineNumber(nr) abort
  let l:buffers = filter(range(1, bufnr("$")), "s:FilterBuffer(v:val)")
  if a:nr <= 0 || a:nr > len(l:buffers)
    return -1
  endif
  return l:buffers[a:nr - 1]
endfunction

function! s:GoToBuffer(nr) abort
  let l:inp = a:nr
  if l:inp == 0
    let l:inp = input("buffer? ")
    " Clear the command line.
    normal :<Esc>
    if empty(l:inp)
      return
    endif
    let l:inp = 0+l:inp
  endif

  if g:vimrc_platform.status_plugin ==? 'lightline'
    let l:num = lightline#bufferline#get_buffer_for_ordinal_number(l:inp)
  elseif g:vimrc_platform.status_plugin ==? 'lualine'
    let l:num = <SID>GetBufferLineNumber(l:inp)
  endif
  if (l:num != -1)
    exe l:num."b"
  else
    echo "Buffer " . l:inp . " doesn't exist."
  endif
endfunction
nnoremap <leader>= <Cmd>call <SID>GoToBuffer(v:count)<CR>

if g:vimrc_platform.status_plugin ==? 'lightline'
  for nr in range(1, 9)
    exe 'nnoremap <leader>' . nr . ' <Plug>lightline#bufferline#go(' . nr . ')'
  endfor
  nnoremap <leader>0 <Plug>lightline#bufferline#go(10)
elseif g:vimrc_platform.status_plugin ==? 'lualine'
  for nr in range(1, 9)
    exe 'nnoremap <leader>' . nr . ' <Cmd>call <SID>GoToBuffer(' . nr . ')<CR>'
  endfor
  nnoremap <leader>0 <Cmd>call <SID>GoToBuffer(10)<CR>
endif
