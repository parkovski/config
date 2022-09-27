function! s:HeaderGuard(label, ns) abort
  if empty(a:label)
    throw "Expected header guard label"
  endif

  let @" = a:label
  normal ggO#ifndef p#define pj#endif /* p */04gg

  if a:ns ==# 'extern "C"'
    normal O#ifdef __cplusplusextern "C" {i#endifGkko#ifdef __cplusplus} /* extern "C" */#endif08gg
  elseif !empty(a:ns)
    let @" = a:ns
    normal Onamespace p {Gkko} // namespace p06gg
  endif
  let @" = ""
endfunction

function! s:HeaderGuardAuto(inner) abort
  normal ggO"%pa_0dwxVU:s/[-/\.]/_/gy$i#ifndef o#define pGo#endif /* p */04gg:noh
  if a:inner ==# 'extern "C"'
    normal O#ifdef __cplusplusextern "C" {i#endifGkko#ifdef __cplusplus} /* extern "C" */#endif08gg
  elseif !empty(a:inner)
    let @" = a:inner
    normal Onamespace " {Gkko} // namespace p06gg
  endif
endfunction

command! -nargs=1 -bar HeaderGuardC call <SID>HeaderGuard(<q-args>, 'extern "C"')
command! -nargs=+ -bar HeaderGuardNS call <SID>HeaderGuard(<f-args>)
command! -nargs=0 -bar HeaderGuardAutoC call <SID>HeaderGuardAuto('extern "C"')
command! -nargs=? -bar HeaderGuardAutoNS call <SID>HeaderGuardAuto(<q-args>)