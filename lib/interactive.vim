let s:base_url = "http://localhost:3000"
let s:poddb_cache_dir = $HOME."/.poddb/cache"
call system("mkdir -p ".s:poddb_cache_dir)

autocmd VimLeave <buffer> :call <SID>write_download_list()<CR>

" main_window() is a list of items, shown from search and by show_podcast_items()
function! s:main_window()
  let s:listbufnr = bufnr('')
  setlocal cursorline
  setlocal nowrap
  setlocal textwidth=0
  setlocal nomodifiable
  noremap <buffer> <cr> :call <SID>show_item()<cr>
  noremap <buffer> l :call <SID>show_item()<cr>
  noremap <buffer> d :call <SID>mark_for_download()<cr>
  noremap <buffer> p :call <SID>show_podcast_items('')<cr>
  noremap <buffer> <c-j> :call <SID>show_next_item(0)<CR> 
  noremap <buffer> <c-k> :call <SID>show_next_item(1)<CR> 
  noremap <buffer> f :call <SID>favorite_this_podcast()<CR> 
  autocmd BufEnter <buffer> :setlocal nowrap
endfunction

function! s:item_window() 
  rightbelow split poddb-item-window
  let s:itembufnr = bufnr('%')
  setlocal buftype=nofile
  noremap <buffer> <c-j> :call <SID>show_next_item(0)<CR> 
  noremap <buffer> <c-k> :call <SID>show_next_item(1)<CR> 
  noremap <buffer> d :call <SID>mark_for_download()<cr>
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
  let command = "curl -s '".s:base_url."/item/".itemId."'"
  let res = system(command)
  call s:focus_window(s:itembufnr)
  silent! 1,$delete
  silent! put! =res
  normal 1G
  wincmd p
endfunc

function! s:mark_for_download() range
  if s:is_podcast_list()
    return
  end
  call s:focus_window(s:listbufnr)
  setlocal modifiable
  let lnum = a:firstline
  while lnum <= a:lastline
    let line = getline(lnum)
    if (match(line, "^*") != -1)
      let newline = substitute(line, '^*', ' ', '')
    else
      let newline = substitute(line, '^ ', '*', '')
    endif
    call setline(lnum, newline)
    let lnum += 1
  endwhile
  setlocal nomodifiable
  write
  redraw
endfunc

function! s:write_download_list() 
  call s:focus_window(s:listbufnr)
  let outfile = s:poddb_cache_dir . "/download_list"
  exec '! cat % | grep "^\*" > '.outfile
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
  call s:focus_window(s:itembufnr)
  close!
  let command = "curl -s '".s:base_url."/podcast/".podcastId."/items'"
  let outfile = s:poddb_cache_dir . "/podcast-" . podcastId . "-itemlist" 
  let contents = system(command)
  call writefile(split(contents, "\n"), outfile)
  exec "e ".outfile
  call s:main_window()
endfunc

function! s:is_podcast_list()
  let top_line = getline(1)
  return top_line =~ "xml_url"
endfunct

function! s:favorite_this_podcast()
  if s:is_podcast_list()
    let podcastId = matchstr( matchstr(getline(line('.')), '\d\+\s*$'), '\d\+' )
  else
    let podcastId = matchstr( matchstr(getline(line('.')), '\d\+ |\s*\d\+$'), '\d\+' )
  endif
  if (podcastId == '')
    return
  endif
  let line = getline('.')
  if (match(line, "^*") != -1)
    let newline = substitute(line, '^*', ' ', '')
  else
    let newline = substitute(line, '^ ', '*', '')
  endif
  setlocal modifiable
  call setline(line('.'), newline)
  setlocal nomodifiable
  write!
  normal 0
  " TODO append podcastId to favorites list

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
  let origbufnr = bufnr('%') 
  let fullscreen = (bufwinnr(s:listbufnr) == -1) " we're in full screen message mode
  if fullscreen
    split
    exec 'b'. s:listbufnr
  else
    call s:focus_window(s:listbufnr)
  end
  if a:previous
    normal k
  else
    normal j
  endif
  call s:show_item()
  normal zz
  if origbufnr == s:itembufnr 
    wincmd p
  endif
  normal 0 
  redraw
endfunction

call s:main_window()
call s:item_window()

normal 3G

