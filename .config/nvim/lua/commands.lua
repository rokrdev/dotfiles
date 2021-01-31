vim.cmd("command! Gcd call custom#GoToRoot()")
vim.cmd("command! Config :e $MYVIMRC")
vim.cmd("command! Reload :so $MYVIMRC")
vim.cmd("command! Tcc call custom#Togglecolorcolumn()")
vim.cmd("command! Scratch call custom#ScratchGenerator()")

-- coc
vim.cmd("command! -nargs=0 Format :call CocAction('format')")
vim.cmd("command! -nargs=0 OR :call CocAction('runCommand', 'editor.action.organizeImport')")

-- fzf
vim.cmd("command! -bang -nargs=* RG call fzf#vim#grep('rg --column --line-number --no-heading --hidden --color=always --smart-case '.shellescape(<q-args>), 1, fzf#vim#with_preview(), <bang>0)")
vim.cmd("command! -bang -nargs=* RGRaw call fzf#vim#grep('rg --column --line-number --no-heading --hidden --color=always --smart-case '.(<q-args>), 1, fzf#vim#with_preview(),  <bang>0)")
vim.cmd("command! -bang -nargs=* GConflicts call fzf#run(fzf#wrap({'source': 'git diff --name-only --diff-filter=U', 'options': ['--multi', '--prompt', 'Conflicts?> ', '--preview', 'cat {}']}, <bang>0))")
vim.cmd("command! -bang -nargs=* LinesWithPreview call fzf#vim#grep('rg --with-filename --column --line-number --no-heading --color=always --smart-case . '.fnameescape(expand('%')), 1,fzf#vim#with_preview({'options': '--delimiter : --nth 4.. --no-sort'}, 'right:50%', '?'), 1)")

-- Term
vim.cmd("command! -bang Term terminal<bang> /usr/local/bin/fish")
vim.cmd("command! -nargs=* T split | Term <args>")
vim.cmd("command! -nargs=* VT vsplit | Term <args>")

-- Session
vim.cmd("command! SS Obsess! | Obsess | wq")

-- whitepace
vim.cmd("command! DisableTrailingWhitespace hi link EndOfLineSpace Normal")
vim.cmd("command! EnableTrailingWhitespace hi link EndOfLineSpace ErrorMsg")

-- Json format
vim.cmd("command! FJ %!jq")

vim.cmd("command! CD cd %:h")

