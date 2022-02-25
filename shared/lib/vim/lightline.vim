let g:lightline = {
      \ 'colorscheme': 'moonfly',
      \ 'tabline': {'left': [['buffers']], 'right': [['tabs']]},
      \ 'component_expand': {'buffers': 'lightline#bufferline#buffers'},
      \ 'component_type': {'buffers': 'tabsel'},
      \ 'inactive': {
      \   'left': [['filename', 'modified']],
      \   'right': [['lineinfo'], ['percent']] },
      \ 'tab': {
      \   'active': ['tabnum', 'name'],
      \   'inactive': ['tabnum', 'name'] },
      \ 'active': {
      \   'left': [['mode', 'paste'], ['readonly', 'filename', 'modified']],
      \   'right': [['lineinfo'], ['percent'],
      \             ['fileformat', 'eol', 'fileencoding', 'filetype']] },
      \ 'component': {'eol': '%{&eol?"eol":"noeol"}'},
      \ 'tab_component_function': {
      \    'tabnum': 'lightline#tab#tabnum',
      \    'name': 'LightlineTabName' },
      \ }

if !exists('g:lightline#tab#names')
  let g:lightline#tab#names = {}
endif
function! LightlineTabName(tabnum) abort
  if has_key(g:lightline#tab#names, a:tabnum)
    return g:lightline#tab#names[a:tabnum]
  endif
  return lightline#tab#filename(tabpagenr())
endfunction
" au TabClosed...
function! SetLightlineTabName(cargs) abort
  let l:args = split(a:cargs, '^[0-9]\+\zs')
  if len(l:args) == 1
    let l:num = tabpagenr()
    let l:name = l:args[0]
  else
    let l:num = l:args[0]
    let l:name = substitute(l:args[1], '^\W\+', '', '')
  endif
  let g:lightline#tab#names[l:num] = l:name
  call lightline#update()
  redrawtabline
endfunction
command! -nargs=1 TabName call SetLightlineTabName(<q-args>)
command! -nargs=1 LightlineColors let g:lightline.colorscheme = <q-args> <bar> call lightline#enable()

let g:lightline#bufferline#show_number = 2 " Bufferline ordinals
let g:lightline#bufferline#unnamed = '[No Name]'
