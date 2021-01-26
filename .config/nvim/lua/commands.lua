local nvim = vim.api

nvim.nvim_command("command! Gcd call custom#GoToRoot()")
nvim.nvim_command("command! Config :e $MYVIMRC")
nvim.nvim_command("command! Reload :so $MYVIMRC")
nvim.nvim_command("command! Tcc call custom#Togglecolorcolumn()")
nvim.nvim_command("command! Scratch call custom#ScratchGenerator()")

-- coc
nvim.nvim_command("command! -nargs=0 Format :call CocAction('format')")
nvim.nvim_command("command! -nargs=0 OR :call CocAction('runCommand', 'editor.action.organizeImport')")

-- fzf
nvim.nvim_command("command! -bang -nargs=* RG call fzf#vim#grep('rg --column --line-number --no-heading --hidden --color=always --smart-case '.shellescape(<q-args>), 1, fzf#vim#with_preview(), <bang>0)")
nvim.nvim_command("command! -bang -nargs=* RGRaw call fzf#vim#grep('rg --column --line-number --no-heading --hidden --color=always --smart-case '.(<q-args>), 1, fzf#vim#with_preview(),  <bang>0)")
nvim.nvim_command("command! -bang -nargs=* GConflicts call fzf#run(fzf#wrap({'source': 'git diff --name-only --diff-filter=U', 'options': ['--multi', '--prompt', 'Conflicts?> ', '--preview', 'cat {}']}, <bang>0))")
nvim.nvim_command("command! -bang -nargs=* LinesWithPreview call fzf#vim#grep('rg --with-filename --column --line-number --no-heading --color=always --smart-case . '.fnameescape(expand('%')), 1,fzf#vim#with_preview({'options': '--delimiter : --nth 4.. --no-sort'}, 'right:50%', '?'), 1)")

-- Term
nvim.nvim_command("command! -bang Term terminal<bang> /usr/local/bin/fish")
nvim.nvim_command("command! -nargs=* T split | Term <args>")
nvim.nvim_command("command! -nargs=* VT vsplit | Term <args>")

-- Session
nvim.nvim_command("command! SS Obsess! | Obsess | wq")

-- whitepace
nvim.nvim_command("command! DisableTrailingWhitespace hi link EndOfLineSpace Normal")
nvim.nvim_command("command! EnableTrailingWhitespace hi link EndOfLineSpace ErrorMsg")

-- Json format
nvim.nvim_command("command! FJ %!jq")
