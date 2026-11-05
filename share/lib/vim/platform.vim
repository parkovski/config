function! g:Chsh(shell) abort
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

function! g:Shellify(str) abort
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
else " not win32
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
