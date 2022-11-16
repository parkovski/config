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
  else
    hi! link VertSplit NONE
  endif

  if has_key(g:colors_opts, 'linenrtocursor')
    hi! link CursorLine LineNr
    hi! link LineNr NONE
  elseif has_key(g:colors_opts, 'cursortolinenr')
    hi! link CursorLine NONE
    hi! link LineNr CursorLine
  else
    hi! link CursorLine NONE
    hi! link LineNr NONE
  endif

  if has_key(g:colors_opts, 'linenrtoleft')
    hi! link SignColumn LineNr
    hi! link FoldColumn LineNr
  else
    hi! link SignColumn NONE
    hi! link FoldColumn NONE
  endif

  if has_key(g:colors_opts, 'linenrtoactive')
    hi! link CursorLineNr LineNr
    hi! link CursorLineSign LineNr
    hi! link CursorLineFold LineNr
  elseif has_key(g:colors_opts, 'fullcursorline')
    hi! link CursorLineNr CursorLine
    hi! link CursorLineSign CursorLine
    hi! link CursorLineFold CursorLine
  else
    hi! link CursorLineNr NONE
    hi! link CursorLineSign NONE
    hi! link CursorLineFold NONE
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

" Possible invocations:
" - No args         -> Print color options.
" - Empty array     -> Load options from ~/.local/etc/vimcolor.
" - Non-empty array -> Apply options and change color scheme to a:1[0].
" - Other           -> Apply options and reload current color scheme.
function! SetColorOptions(...) abort
  if a:0 == 0
    echo g:colors_opts
    return
  endif

  " Fix args so that l:opts is an array of [color scheme, options, ...]
  if type(a:1) == v:t_list && a:0 == 1
    " Single list argument.
    if len(a:1) == 0
      try
        let l:opts = readfile(glob('~/.local/etc/vimcolor'))
      catch
        return
      endtry
    else
      let l:opts = a:1
    endif
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

  if has_key(g:, 'rainbow_conf')
    let g:rainbow_conf.guifgs = g:vimrc_platform.rainbow_colors[&background]
    "RainbowToggleOn
  endif

  if !empty(l:opts[0])
    " New color scheme in l:opts[0].
    " If it contains a '/', the left side is light mode and the right side is
    " dark mode.
    let l:slash = stridx(l:opts[0], "/")
    if l:slash == -1
      let l:scheme = l:opts[0]
    elseif &background ==# "light"
      let l:scheme = strpart(l:opts[0], 0, l:slash)
    else
      let l:scheme = strpart(l:opts[0], l:slash + 1)
    endif
    exe 'silent! colorscheme ' . l:scheme
  else
    " Reload current color scheme.
    exe 'silent! colorscheme '.g:colors_name
  endif
endfunction

" Without args: Prints g:colors_opts.
" With args: Sets color options.
command! -bang -bar -nargs=* ColorOptions
      \ if !empty("<bang>") | let g:colors_opts = {} | endif |
      \ call SetColorOptions(<f-args>)

" Without args: Reloads default color scheme.
" With args: Sets color scheme and options.
command! -bang -bar -nargs=* -complete=color ColorScheme
      \ if !empty("<bang>") | let g:colors_opts = {} | endif |
      \ call SetColorOptions([<f-args>])

augroup VimrcColors
  autocmd!

  autocmd ColorSchemePre * silent! call remove(g:, 'colors_name')
  autocmd ColorScheme * call TryToFixColorScheme()
augroup END

if !v:vim_did_enter
  call SetColorOptions([])
endif
