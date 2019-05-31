let s:save_cpo = &cpoptions
set cpoptions&vim

let s:popup = {
      \ 'env': 'vim',
      \ }

function! s:init_win(winid, opts) abort
  call setwinvar(a:winid, '&signcolumn', 'no')

  let bufnr = winbufnr(a:winid)
  if has_key(a:opts, 'filetype')
    call setbufvar(bufnr, '&filetype', a:opts['filetype'])
  endif
endfunction

function! s:popup.is_supported() abort
  return exists('*popup_create')
endfunction

function! s:popup.open(texts, ...) abort
  if !self.is_supported() | return | endif

  let opts = get(a:, 1, {})
  if type(a:texts) != v:t_list || empty(a:texts)
    return
  endif

  let view = winsaveview()
  let line = get(opts, 'line', view['lnum'])
  let row = get(opts, 'row', line - view['topline'] + 1)
  let col = get(opts, 'col', len(getline('.')) + 1) - 1

  let wininfo = getwininfo(win_getid())[0]
  let row = row + wininfo['winrow'] - 2
  let col = col + wininfo['wincol'] - 1

  let max_width = &columns - col - 5
  let width = max(map(copy(a:texts), {_, v -> len(v)})) + 1
  let height = len(a:texts)

  let win_opts = {
        \ 'line': row + 1,
        \ 'col': col + 1,
        \ 'minwidth': width,
        \ 'maxwidth': max_width,
        \ 'minheight': height,
        \ 'maxheight': g:iced#popup#max_height,
        \ }

  if get(opts, 'auto_close', v:true)
    let win_opts['time'] = get(opts, 'close_time', g:iced#popup#time)
  endif

  if has_key(opts, 'highlight')
    let win_opts['highlight'] = opts['highlight']
  endif

  let winid = popup_create(a:texts, win_opts)
  call s:init_win(winid, opts)

  return winid
endfunction

function! s:popup.close(window_id) abort
  if !self.is_supported() | return | endif
  call popup_close(a:window_id)
endfunction

function! iced#di#popup#vim#build(container) abort
  return s:popup
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
