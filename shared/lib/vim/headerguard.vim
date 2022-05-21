function! s:HeaderGuard(inner) abort
  normal ggO"%pa_0dwxVU:s/[/\.]/_/gy$i#ifndef o#define pGo#endif /* p */03gg:noh
  if a:inner ==# 'extern "C"'
    normal o#ifdef __cplusplusextern "C" {i#endifGkko#ifdef __cplusplus} /* extern "C" */#endif08gg
  elseif !empty(a:inner)
    let @" = a:inner
    normal onamespace " {Gkko} // namespace p06gg
  endif
endfunction

command! -nargs=? -bar HeaderGuard call <SID>HeaderGuard(<q-args>)
command! -nargs=0 -bar HeaderGuardExternC call <SID>HeaderGuard('extern "C"')