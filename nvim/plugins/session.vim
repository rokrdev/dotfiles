let g:session_directory = "~/.vim/session"
let g:session_autoload = "no"
let g:session_autosave = "no"
let g:session_command_alias = 1

let g:nnn#set_default_mappings = 0

nnoremap <Leader>so :OpenSession<Space>
nnoremap <Leader>ss :SaveSession<Space>
nnoremap <Leader>sd :DeleteSession<CR>
nnoremap <Leader>sc :CloseSession<CR>
nnoremap <Leader>sc :CloseSession<CR>
nnoremap <Leader>sn :SaveSession default<CR> :OpenSession NOTES<CR>

