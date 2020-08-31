" " Creates a floating window with a most recent buffer to be used
" function! CreateCenteredFloatingWindow(opts)
"   let width = float2nr(&columns * a:opts.width)
"   let height = float2nr(&lines * a:opts.height)
"   let row = ((&lines - height) / 2) - 1
"   let col = (&columns - width) / 2
"   let opts = {
"         \ 'relative': 'editor',
"         \ 'row': row,
"         \ 'col': col,
"         \ 'width': width,
"         \ 'height': height,
"         \ 'style': 'minimal'
"         \ }

"   let top = "╭" . repeat("─", width - 2) . "╮"
"   let mid = "│" . repeat(" ", width - 2) . "│"
"   let bot = "╰" . repeat("─", width - 2) . "╯"
"   let lines = [top] + repeat([mid], height - 2) + [bot]
"   let s:buf = nvim_create_buf(v:false, v:true)
"   call nvim_buf_set_lines(s:buf, 0, -1, v:true, lines)
"   call nvim_open_win(s:buf, v:true, opts)
"   set winhl=Normal:Floating
"   let opts.row += 1
"   let opts.height -= 2
"   let opts.col += 2
"   let opts.width -= 4
"   call nvim_open_win(nvim_create_buf(v:false, v:true), v:true, opts)
"   autocmd BufWipeout <buffer> exe 'bwipeout '.s:buf
" endfunction

" When term starts, auto go into insert mode
autocmd TermOpen * startinsert

" Turn off line numbers etc
autocmd TermOpen * setlocal listchars= nonumber norelativenumber

" function! OpenTerm(cmd, opts)
"   if empty(bufname(a:cmd))
"     call CreateCenteredFloatingWindow(a:opts)
"     call termopen(a:cmd, { 'on_exit': function('OnTermExit') })
"   else
"     bwipeout!
"   endif
" endfunction

" function! OpenScratchTerm()
"     call OpenTerm('fish', {'height': 0.9, 'width': 0.9})
" endfunction

" function! OpenLazyGit()
"     call OpenTerm('lazygit', {'height': 0.95, 'width': 0.95})
" endfunction

function! OnTermExit(job_id, code, event) dict
  if a:code == 0
    bwipeout!
  endif
  set laststatus=2
endfunction

function! OpenTig(cmd)
  execute 'enew'
  set laststatus=0
  call termopen(a:cmd, { 'on_exit': function('OnTermExit') })
endfunction

nmap <Leader>gg :call OpenTig('tig status')<CR>
nmap <Leader>gb :call OpenTig('tig ' . expand('%'))<CR>
nmap <Leader>gu :call OpenTig('tig log @{u}.. -p')<CR>

highlight NormalFloat cterm=NONE ctermfg=14 ctermbg=0 gui=NONE guifg=#93a1a1 guibg=#002931
