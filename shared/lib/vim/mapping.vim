imap <NUL> <C-Space>
noremap! <Char-0x7F> <BS>

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
inoremap <silent> <expr> <Esc> AutoCompleteCancel()
inoremap <silent> <expr> <C-d> pumvisible() ? "\<PageDown>" : "\<C-d>"
inoremap <silent> <expr> <C-u> pumvisible() ? "\<PageUp>" : "\<C-u>"

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
elseif $VIM_LANGCLIENT ==? 'coc'
  nmap <silent><expr> <C-Space> coc#refresh()

  nmap <silent> [g <Plug>(coc-diagnostic-prev)
  nmap <silent> ]g <Plug>(coc-diagnostic-next)

  " GoTo code navigation.
  nmap <silent> gd <Plug>(coc-definition)
  nmap <silent> gy <Plug>(coc-type-definition)
  nmap <silent> gi <Plug>(coc-implementation)
  nmap <silent> gr <Plug>(coc-references)

  nmap <silent> <F2> <Plug>(coc-rename)

  " Use K to show documentation in preview window.
  nnoremap <silent> K :call <SID>show_documentation()<CR>

  function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
      execute 'h '.expand('<cword>')
    else
      call CocAction('doHover')
    endif
  endfunction
endif

nnoremap <M->> <C-w>8>
nnoremap <M--> <C-w>8-
nnoremap <M-+> <C-w>8+
nmap <M-=> <M-+>
nnoremap <M-lt> <C-w>8<

noremap! <M-h> <Left>
noremap! <M-j> <Down>
noremap! <M-k> <Up>
noremap! <M-l> <Right>
noremap! <M-b> <S-Left>
noremap! <M-e> <S-Right>
" noremap! <C-a> <Home>
" noremap! <C-e> <End>

noremap! <C-r><C-r> <C-r>"
noremap! <C-_> <C-r>+
noremap <C-_> "+

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

" Swap with deleted text
xnoremap <C-s> <Esc>`.``gvP``P

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
nnoremap <silent> <leader>P "+p
" nnoremap <leader>Y "+Y
" xnoremap <leader>Y "+y
nnoremap <silent> <leader>r :set relativenumber!<CR>

nnoremap <silent> <leader><Tab> :tabnext<CR>
nnoremap <silent> <leader><S-Tab> :tabprevious<CR>
nnoremap <silent> <leader>N :tabedit %<CR>
nnoremap <silent> <leader>Q :tabclose<CR>
nnoremap <silent> <leader>H :-tabmove<CR>
nnoremap <silent> <leader>L :+tabmove<CR>
nnoremap <silent> <leader>_ :tabfirst<CR>
nnoremap <silent> <leader>+ :tablast<CR>

for nr in range(1, 9)
  exe 'nnoremap <silent> <leader>' . nr . ' :b' . nr . '<CR>'
endfor
nnoremap <silent> <leader>0 :b10<CR>
