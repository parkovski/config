function! s:HeaderGuard(inner) abort
  normal ggO"%pa_0dwxVU:s/[/\.]/_/gy$i#ifndef o#define pGo#endif /* p */gg3j0:noh
  if a:inner ==# 'extern "C"'
    normal O#ifdef __cplusplusextern "C" {i#endifGkko#ifdef __cplusplus} /* extern "C" */#endifgg5j0
  elseif !empty(a:inner)
    let @" = a:inner
    normal Onamespace " {Gkko} // namespace pgg5j0
  endif
endfunction

command! -nargs=? -bar HeaderGuard call <SID>HeaderGuard(<args>)
command! -nargs=0 -bar HeaderGuardExternC call <SID>HeaderGuard('extern "C"')