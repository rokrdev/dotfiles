function! OpenTig(cmd, title)
  execute 'FloatermNew --height=0.99 --width=0.99 --autoclose=1 --name='. a:title . ' ' . a:cmd
endfunction

nmap <Leader>gg :call OpenTig('tig status', 'Status')<CR>
nmap <Leader>gb :call OpenTig('tig ' . expand('%'), 'Blame')<CR>
nmap <Leader>gu :call OpenTig('tig log @{u}.. -p', 'Unpushed')<CR>

" highlight FloatermBorder guifg=#c792ea
