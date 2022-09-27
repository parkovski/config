let g:colors_opts = {}
function! TryToFixColorScheme() abort
  if has_key(g:, 'colors_name')
    " if has_key(g:, 'lightline#colorscheme#'.g:colors_name.'#palette')
    "   let g:lightline.colorscheme = g:colors_name
    "   silent! call lightline#enable()
    " endif

    let l:fn = glob('~/.share/etc/fix-' . g:colors_name . '.vim')
    if filereadable(fn)
      exe 'source ' . l:fn
    endif
  endif

  if has_key(g:colors_opts, 'transparent')
    hi Normal guibg=NONE
    hi EndOfBuffer guibg=NONE
    hi LineNr guibg=NONE
    hi SignColumn guibg=NONE
    hi FoldColumn guibg=NONE
    hi! link VertSplit LineNr
  elseif has_key(g:colors_opts, 'transparentsrc')
    hi Normal guibg=NONE
    hi EndOfBuffer guibg=NONE
    hi! link VertSplit LineNr
  endif

  if has_key(g:colors_opts, 'linenrtocursor')
    hi! link CursorLine LineNr
  elseif has_key(g:colors_opts, 'cursortolinenr')
    hi! link LineNr CursorLine
  endif

  if has_key(g:colors_opts, 'linenrtoleft')
    hi! link SignColumn LineNr
    hi! link FoldColumn LineNr
  endif

  if has_key(g:colors_opts, 'linenrtoactive')
    hi! link CursorLineNr LineNr
    hi! link CursorLineSign LineNr
    hi! link CursorLineFold LineNr
  elseif has_key(g:colors_opts, 'fullcursorline')
    hi! link CursorLineNr CursorLine
    hi! link CursorLineSign CursorLine
    hi! link CursorLineFold CursorLine
  endif

  if has_key(g:colors_opts, 'setindentguides')
    hi IndentGuidesEven guibg=#344162
    hi IndentGuidesOdd guibg=#344f62
  endif

  if has_key(g:colors_opts, 'run')
    for l:cmd in g:colors_opts.run
      silent! exe l:cmd
    endfor
  endif
endfunction

" Arguments are either a single list where the first item is the color scheme
" name, or 1 or more string arguments where all are options.
function! SetColorOptions(...) abort
  if a:0 == 0
    return
  endif

  if type(a:1) == v:t_list && a:0 == 1
    " Called with list: First arg is the color scheme.
    let l:opts = a:1
    let l:len = len(l:opts)
  else
    " Called with args: Don't set color scheme - all args are options.
    let l:opts = [''] + a:000
    let l:len = 1 + a:0
  endif

  let l:i = 1
  while l:i < l:len
    if l:opts[l:i] ==# 'dark' || l:opts[l:i] ==# 'light'
      exe 'silent! set bg='.l:opts[l:i]
    elseif l:opts[l:i] ==? 'reset'
      let g:colors_opts = {}
    elseif !empty(l:opts[l:i])
      if l:opts[l:i][0] ==# ':'
        if !has_key(g:colors_opts, 'run')
          let g:colors_opts.run = []
        endif
        call add(g:colors_opts.run, strpart(l:opts[l:i], 1))
      elseif l:opts[l:i][0] ==# '"'
        " comment
      elseif l:opts[l:i][0:1] ==# 'no'
        unlet! g:colors_opts[l:opts[l:i][2:]]
      else
        let g:colors_opts[l:opts[l:i]] = 1
      endif
    endif
    let l:i += 1
  endwhile

  if !empty(l:opts[0])
    exe 'silent! colorscheme '.l:opts[0]
  elseif l:len > 1 && has_key(g:, 'colors_name')
    exe 'silent! colorscheme '.g:colors_name
  else
    call TryToFixColorScheme()
  endif
endfunction

augroup VimrcColors
  autocmd!

  autocmd ColorSchemePre * silent! call remove(g:, 'colors_name')
  autocmd ColorScheme * call TryToFixColorScheme()
augroup END

if !v:vim_did_enter
  silent! call SetColorOptions(readfile(glob('~/.local/etc/vimcolor')))
endif
