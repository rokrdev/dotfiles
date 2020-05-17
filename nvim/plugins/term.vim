
autocmd TermOpen * startinsert
autocmd TermOpen * setlocal listchars= nonumber norelativenumber
autocmd TermOpen * tnoremap <buffer> <Esc> <c-\><c-n>
autocmd TermOpen * IndentLinesDisable

command! -bang Term terminal<bang> /usr/local/bin/fish
command! -nargs=* T split | Term <args>
command! -nargs=* VT vsplit | Term <args>

nnoremap <Leader>ts :T<CR>
nnoremap <Leader>tv :VT<CR>
