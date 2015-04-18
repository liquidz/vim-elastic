""
" Elastic plugin for vim.
"

let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of('elastic')
let s:Http = s:V.import('Web.HTTP')
let s:Json = s:V.import('Web.JSON')

""
" @var
" Elastic url.
" Default value is 'http://localhost:9200'.
"
if !exists('g:elastic#url')
  let g:elastic#url = 'http://localhost:9200'
endif

function! s:constructUrl(index, ...) abort
  if len(a:000) ==# 0
    let url =  g:elastic#url . '/' . a:index
  else
    let url =  g:elastic#url . '/' . a:index . '/' . a:000[0]
  endif

  return url
endfunction

""
" Post data to elastic.
"
function! elastic#post(index, type, data) abort
  let url = s:constructUrl(a:index, a:type)
  let json = s:Json.encode(a:data)
  return s:Http.post(url, json)
endfunction

""
" Delete from elastic.
"
" Example: >
"   echo elastic#delete('index')
"   echo elastic#delete('index', 'type')
" <
function! elastic#delete(...) abort
  let url = call('s:constructUrl', a:000)
  return s:Http.request(url, {'method': 'DELETE'})
endfunction

""
" Get data from elastic.
"
" Example: >
"   echo elastic#get('index')
"   echo elastic#get('index', 'type')
" <
function! elastic#get(...) abort
  let url = call('s:constructUrl', a:000) . '/_search'
  let resp = s:Http.get(url)

  if resp['statusText'] ==# 'OK'
    return s:Json.decode(resp['content'])
  else
    return {}
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
