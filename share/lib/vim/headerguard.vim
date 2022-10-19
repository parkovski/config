function! s:HeaderGuard(label, ns) abort
  if empty(a:label)
    throw "Expected header guard label"
  endif

  let @" = a:label
  normal ggO#ifndef p

  if a:ns ==# 'extern "C"'
    normal O#ifdef __cplusplus
  elseif !empty(a:ns)
    let @" = a:ns
    normal Onamespace p {
  endif
  let @" = ""
endfunction

function! s:HeaderGuardAuto(inner) abort
  normal ggO"%pa_0dwxVU:s/[-/\.]/_/g
  if a:inner ==# 'extern "C"'
    normal O#ifdef __cplusplus
  elseif !empty(a:inner)
    let @" = a:inner
    normal Onamespace " {
  endif
endfunction

command! -nargs=1 -bar HeaderGuardC call <SID>HeaderGuard(<q-args>, 'extern "C"')
command! -nargs=+ -bar HeaderGuardNS call <SID>HeaderGuard(<f-args>)
command! -nargs=0 -bar HeaderGuardAutoC call <SID>HeaderGuardAuto('extern "C"')
command! -nargs=? -bar HeaderGuardAutoNS call <SID>HeaderGuardAuto(<q-args>)