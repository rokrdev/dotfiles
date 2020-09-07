let g:floaterm_shell="fish"

function! OpenFloaterm(cmd, title, height, width, ...)
  let pre = a:0 >= 1 ? a:1 : ''
  exe pre

  let cmdList = ['FloatermNew']
  call add(cmdList, '--height='.string(a:height))
  call add(cmdList, '--width='.string(a:width))
  call add(cmdList, '--autoclose=1')
  call add(cmdList, '--name='.a:title)
  call add(cmdList, a:cmd)

  exe join(cmdList, ' ')
endfunction

nmap <Leader>gg :call OpenFloaterm('tig status', 'Status', 0.99, 0.99)<CR>
nmap <Leader>gb :call OpenFloaterm('tig ' . expand('%'), 'Blame', 0.99, 0.99)<CR>
nmap <Leader>gu :call OpenFloaterm('tig log @{u}.. -p', 'Unpushed', 0.99, 0.99)<CR>
nmap <Leader>n :call OpenFloaterm('nnn -d', 'NNN', 0.60, 0.80, 'lcd %:p:h')<CR>
" nmap <Leader>- :call OpenFloaterm('', 'Term', 0.60, 0.80)<CR>

highlight FloatermBorder guifg=#82aaff
