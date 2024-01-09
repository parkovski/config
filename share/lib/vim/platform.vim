let g:vimrc_platform = {}

if has("nvim") || has("lua")
  let g:vimrc_platform.status_plugin = 'lualine'
else
  let g:vimrc_platform.status_plugin = 'lightline'
endif

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

  let g:vimrc_platform.dotvim = glob('~/.vim')
  if empty(g:vimrc_platform.dotvim)
    let g:vimrc_platform.dotvim = glob('~/vimfiles')
  endif
  let g:vimrc_platform.temp = $TEMP
  let g:vimrc_platform.lcinstall = 'pwsh.exe -nologo -nop -noni -file install.ps1'
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

augroup VimrcPlatform
  autocmd!

  if (has('win32') && !empty(exepath($GH . "/conutils/isvt.exe")))
    command! Conflags exe "!".
          \ $GH."/conutils/isvt.exe -p".
          \ " $([System.Diagnostics.Process]::GetCurrentProcess().Parent.Id)"
    " if has('nvim')
      " Fix some nvim glitches
      " autocmd VimEnter * exe "silent !".
      "     \ $GH."/conutils/isvt.exe -p".
      "     \ " $([System.Diagnostics.Process]::GetCurrentProcess().Parent.Id)".
      "     \ " o=_+DISABLE_NEWLINE_AUTO_RETURN"
    " endif
  endif
augroup END
