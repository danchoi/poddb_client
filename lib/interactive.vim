let s:client_cmd = "poddb"
if !exists($PODDB_SERVER)
  let g:poddb_base_url = $PODDB_SERVER
else
  let g:poddb_base_url = "http://poddb.com"
endif


let s:download_and_play_cmd = s:client_cmd." --download-and-play "

let s:poddb_cache_dir = $HOME."/.poddb/cache"
call system("mkdir -p ".s:poddb_cache_dir)
let s:favorite_podcasts_list = $HOME."/.poddb/favorites"

let s:download_list = []

autocmd VimLeave * :call <SID>write_download_list()<CR>

function! PoddbStatusLine()
  return "%<%f\ | Press ".g:mapleader."? for help. "."%r%=%-14.(%l,%c%V%)\ %P"
endfunction

" main_window() is a list of items, shown from search and by show_podcast_items()
function! s:main_window()
  let s:listbufnr = bufnr('')
  setlocal cursorline
  setlocal nowrap
  setlocal textwidth=0
  setlocal nomodifiable
  setlocal statusline=%!PoddbStatusLine()
  noremap <buffer> <cr> :call <SID>show_item()<cr>
  noremap <buffer> l :call <SID>show_item()<cr>
  noremap <buffer> d :call <SID>mark_for_download()<cr>
  noremap <buffer> D :call <SID>download_and_play()<cr>
  noremap <buffer> p :call <SID>show_podcast_items('')<cr>
  noremap <buffer> <c-j> :call <SID>show_next_item(0)<CR> 
  noremap <buffer> <c-k> :call <SID>show_next_item(1)<CR> 
  noremap <buffer> f :call <SID>favorite_this_podcast()<CR> 
  autocmd BufEnter <buffer> :setlocal nowrap | let s:listbufnr = bufnr('') 
  autocmd BufWinEnter <buffer> :only
  noremap <buffer> <Leader>? :call <SID>help()<CR>
endfunction

function! s:item_window() 
  rightbelow split poddb-item-window
  let s:itembufnr = bufnr('%')
  setlocal buftype=nofile
  noremap <buffer> <c-j> :call <SID>show_next_item(0)<CR> 
  noremap <buffer> <c-k> :call <SID>show_next_item(1)<CR> 
  noremap <buffer> d :call <SID>mark_for_download()<cr>
  nnoremap <buffer> o :call <SID>find_next_href_and_open()<CR>
  nnoremap <buffer> O :call <SID>open_all_hrefs()<CR>
  close
endfunction

function! s:show_item()
  if s:is_podcast_list()
    let podcastId = matchstr( matchstr(getline(line('.')), '\d\+\s*$'), '\d\+' )
    call s:show_podcast_items(podcastId)
    return
  else
    let itemId = matchstr(getline(line('.')), '\d\+$')
  endif
  if (itemId == '')
    return
  endif
  let command = "curl -s '".g:poddb_base_url."/item/".itemId."'"
  let res = system(command)
  call s:focus_window(s:itembufnr)
  setlocal modifiable
  silent! 1,$delete
  silent! put! =res
  setlocal nomodifiable
  normal 1G
  wincmd p
endfunc

function! s:mark_for_download() range
  if s:is_podcast_list()
    return
  end
  call s:focus_window(s:listbufnr)
  let itemId = matchstr( matchstr(getline(line('.')), '\d\+\s*$'), '\d\+' )
  if itemId == ''
    return
  endif
  setlocal modifiable
  let lnum = a:firstline
  while lnum <= a:lastline
    let line = getline(lnum)
    if (match(line, "^*") != -1)
      let newline = substitute(line, '^*', ' ', '')
      call filter(s:download_list, 'v:val == itemId')  
    else
      let newline = substitute(line, '^.', '*', '')
      call add(s:download_list, itemId)
    endif
    call setline(lnum, newline)
    let lnum += 1
  endwhile
  setlocal nomodifiable
  write
  redraw
endfunc

function! s:write_download_list() 
  let outfile = s:poddb_cache_dir . "/download_list"
  echo s:download_list
  " sleep 1
  call writefile(s:download_list, outfile)
endfunc

function! s:show_podcast_items(podcastId)
  " Let user use p key from podcastlist and itemlist
  " If p is pressed in podcastlist, podcastId will be blank, and we'll reuse
  " s:show_item() to extract podcastId and call this method again.
  if s:is_podcast_list() && a:podcastId == ''
    call s:show_item()
    return
  end
  if a:podcastId != ''
    let podcastId = a:podcastId
  else
    let podcastId = matchstr( matchstr(getline(line('.')), '\d\+ |\s*\d\+$'), '\d\+' )
  end
  if (podcastId == '')
    return
  endif
  let command = "curl -s '".g:poddb_base_url."/podcast/".podcastId."/items'"
  let contents = system(command)
  if contents =~ 'No matches\c'
    echom "No items!"
    return
  endif
  call s:focus_window(s:itembufnr)
  close!
  let outfile = s:poddb_cache_dir . "/podcast-" . podcastId . "-itemlist" 
  call writefile(split(contents, "\n"), outfile)
  exec "e+3 ".outfile
  call s:main_window()
endfunc

function! s:is_podcast_list()
  let top_line = getline(1)
  return top_line =~ "xml_url"
endfunct

function! s:favorite_this_podcast()
  let is_podcast_list = s:is_podcast_list()
  if is_podcast_list
    let podcastId = matchstr( matchstr(getline(line('.')), '\d\+\s*$'), '\d\+' )
  else
    let podcastId = matchstr( matchstr(getline(line('.')), '\d\+ |\s*\d\+$'), '\d\+' )
  endif
  if (podcastId == '')
    return
  endif
  if !is_podcast_list
    call system("grep '^".podcastId."$' ".s:favorite_podcasts_list." ||  echo ".podcastId." >> ".s:favorite_podcasts_list)
    echom "Added this podcast to favorites"
    return
  end
  let line = getline('.')
  if (match(line, "^@") != -1)
    let newline = substitute(line, '^@', ' ', '')
    let tmp = tempname()
    " alter favorites file 
    call system("grep -v '^".podcastId."$' ".s:favorite_podcasts_list." | uniq > ".tmp."  &&  mv ".tmp." ".s:favorite_podcasts_list)
  else
    let newline = substitute(line, '^ ', '@', '')
    " append to favorites file 
    call system("echo ".podcastId." >> ".s:favorite_podcasts_list)
  endif
  setlocal modifiable
  call setline(line('.'), newline)
  setlocal nomodifiable
  write!
  normal 0
endfunc

function! s:download_and_play()
  let itemId = matchstr( matchstr(getline(line('.')), '\d\+\s*$'), '\d\+' )
  let outfile = s:poddb_cache_dir . "/download_and_play"
  call system("echo ".itemId." > ".outfile)
  call writefile(itemId, outfile)
  qa!
endfunc

function! s:focus_window(target_bufnr)
  if bufwinnr(a:target_bufnr) == winnr() 
    return
  end
  let winnr = bufwinnr(a:target_bufnr) 
  if winnr == -1
    if a:target_bufnr == s:listbufnr
      leftabove split
    else
      rightbelow split
    endif
    exec "buffer" . a:target_bufnr
  else
    exec winnr . "wincmd w"
  endif
endfunction

function! s:show_next_item(previous)
  if s:is_podcast_list()
    return
  end
  call s:focus_window(s:listbufnr)
  if a:previous
    normal k
  else
    normal j
  endif
  call s:show_item()
  normal zz
  normal 0 
  redraw
endfunction

function! s:help()
  " This just displays the README
  let res = system(s:client_cmd." --key-mappings")
  echo res  
endfunction

" ------------------------------------------------------------------------ 
" open links in external browser 

if !exists("g:Poddb#browser_command")
  for cmd in ["gnome-open", "open"] 
    if executable(cmd)
      let g:Poddb#browser_command = cmd
      break
    endif
  endfor
  if !exists("g:Poddb#browser_command")
    echom "Can't find the to open your web browser."
  endif
endif

let s:http_link_pattern = 'https\?:[^ >)\]]\+'

func! s:open_href_under_cursor()
  let href = matchstr(expand("<cWORD>") , s:http_link_pattern)
  let command = g:Poddb#browser_command . " '" . shellescape(href) . "' "
  call system(command)
endfunc

func! s:find_next_href_and_open()
  let res = search(s:http_link_pattern, 'cw')
  if res != 0
    call s:open_href_under_cursor()
  endif
endfunc

func! s:open_all_hrefs()
  let n = 0
  let line = search(s:http_link_pattern, 'cw')
  while line
    call s:open_href_under_cursor()
    let n += 1
    let line = search(s:http_link_pattern, 'W')
  endwhile
  echom 'opened '.n.' links' 
endfunc

" ------------------------------------------------------------------------


call s:main_window()
call s:item_window()

normal 3G


