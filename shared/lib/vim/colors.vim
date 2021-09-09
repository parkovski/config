let g:colors_opts = {}
function! TryToFixColorScheme() abort
  if !has_key(g:, 'colors_name')
    return
  endif

  let l:fn = glob('~/shared/etc/fix-' . g:colors_name . '.vim')
  if filereadable(fn)
    exe 'source ' . l:fn
  endif

  if has_key(g:colors_opts, 'transparent')
    hi Normal guibg=NONE
    hi EndOfBuffer guibg=NONE
    hi LineNr guibg=NONE
    hi SignColumn guibg=NONE
    hi FoldColumn guibg=NONE
    hi VertSplit guibg=NONE guifg=white
  endif

  if has_key(g:colors_opts, 'linenrtoactive')
    hi! link LineNr CursorLineNr
  elseif has_key(g:colors_opts, 'linenrtocursor')
    hi! link LineNr CursorLine
  endif

  if has_key(g:colors_opts, 'setindentguides')
    hi IndentGuidesEven guibg=#344162
    hi IndentGuidesOdd guibg=#344f62
  endif
endfunction

function! SetColorOptions(...) abort
  if a:0 == 0
    return
  endif
  if type(a:1) == v:t_list && a:0 == 1
    let l:opts = a:1
    let l:len = len(l:opts)
  else
    let l:opts = a:000
    let l:len = a:0
  endif

  let l:i = 1
  while l:i < l:len
    if l:opts[l:i] ==# 'dark' || l:opts[l:i] ==# 'light'
      exe 'silent! set bg='.l:opts[l:i]
    elseif l:opts[l:i] ==? 'reset'
      let g:colors_opts = {}
    elseif !empty(l:opts[l:i])
      let g:colors_opts[l:opts[l:i]] = 1
    endif
    let l:i += 1
  endwhile
  if !empty(l:opts[0])
    exe 'silent! colorscheme '.l:opts[0]
  elseif l:len > 1
    exe 'silent! colorscheme '.g:colors_name
  endif
endfunction

augroup VimrcColors
  autocmd!

  autocmd ColorSchemePre * silent call remove(g:, 'colors_name')
  autocmd ColorScheme * call TryToFixColorScheme()
augroup END

silent! call SetColorOptions(readfile(glob('~/local/etc/vimcolor')))
