noremap  <NUL> <C-Space>
noremap! <NUL> <C-Space>
noremap  <Char-0x7F> <BS>
noremap! <Char-0x7F> <BS>

tnoremap <C-a> <C-\><C-n>
tnoremap <C-a><C-a> <C-a>

lua <<EOF
function AutoCompleteTab()
  if vim.fn.pumvisible() ~= 0 then
    return '<C-n>'
  elseif vim.snippet.active({ direction = 1 }) then
    return '<Cmd>lua vim.snippet.jump(1)<CR>'
  else
    return '<Tab>'
  end
end

function AutoCompleteShiftTab()
  if vim.fn.pumvisible() ~= 0 then
    return '<C-p>'
  elseif vim.snippet.active({ direction = -1 }) then
    return '<Cmd>lua vim.snippet.jump(-1)<CR>'
  else
    return '<S-Tab>'
  end
end

function AutoCompleteCancel()
  if vim.fn.pumvisible() ~= 0 then
    if vim.v.completed_item == nil or not next(vim.v.completed_item) then
      if vim.snippet.active() then
        return '<C-e>'
      else
        return '<C-e><Esc>'
      end
    else
      return '<C-e>'
    end
  else
    return '<Esc>'
  end
end

vim.keymap.set('i', '<Tab>', AutoCompleteTab, { noremap = true, silent = true, expr = true })
vim.keymap.set('i', '<S-Tab>', AutoCompleteShiftTab, { noremap = true, silent = true, expr = true })
vim.keymap.set('i', '<Esc>', AutoCompleteCancel, { noremap = true, silent = true, expr = true })
EOF

function s:Backspace()
  if pumvisible()
    return "\<C-e>\<BS>"
  endif
  return "\<BS>"
endfunction

function! s:AutoCompleteSelect()
  if pumvisible()
    if empty(v:completed_item)
      return "\<C-e>\<CR>"
    endif
    return "\<C-y>"
  endif

  return "\<CR>"
endfunction

function! s:AutoCompleteJumpBackwards()
  if pumvisible()
    return "\<C-p>"
  endif

  return "\<S-Tab>"
endfunction

function! s:ScrollDown()
  if pumvisible()
    return "\<PageDown>"
  else
    return "\<C-d>"
  endif
endfunction

function! s:ScrollUp()
  if pumvisible()
    return "\<PageUp>"
  else
    return "\<C-u>"
  endif
endfunction

inoremap <silent><expr> <BS>    <SID>Backspace()
snoremap <silent><expr> <BS>    <SID>Backspace()
inoremap <silent><expr> <CR>    <SID>AutoCompleteSelect()
snoremap <silent><expr> <CR>    <SID>AutoCompleteSelect()
inoremap <silent><expr> <C-d>   <SID>ScrollDown()
snoremap <silent><expr> <C-d>   <SID>ScrollDown()
inoremap <silent><expr> <C-u>   <SID>ScrollUp()
snoremap <silent><expr> <C-u>   <SID>ScrollUp()

map W <Cmd>lua require('spider').motion('w')<CR>
map E <Cmd>lua require('spider').motion('e')<CR>
map B <Cmd>lua require('spider').motion('b')<CR>

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
nnoremap <leader>c <Cmd>ColorScheme<CR>

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
