local cmd = vim.cmd
local commands = {}

function commands.setup()
  cmd("command! Gcd lua require('utils').goToRoot()")
  cmd("command! Reload :so $MYVIMRC | echo 'Config Reloaded'")
  cmd("command! Tcc lua require('utils').toggleColorColumn()")
  cmd("command! Scratch lua require('utils').scratchGenerator()")

  -- dotfiles
  cmd("command! Dfc lua require('keymap.custom').clear_buffers_from_path({loc = '/.dotfiles/'})")
  cmd("command! Dff lua require('keymap.custom').custom_find({title = 'Dotfiles Find', loc = vim.g.dotfiles_loc})")
  cmd("command! Dfs lua require('keymap.custom').custom_search({title = 'Dotfiles Search', loc = vim.g.dotfiles_loc})")
  cmd("command! Dfg lua require('keymap.custom').custom_grep({title = 'Dotfiles Grep', loc = vim.g.dotfiles_loc})")

  -- git
  cmd("command! Ga execute ':silent !git add %'")
  cmd("command! Gr execute ':silent !git reset %'")
  cmd("command! Gg lua require'gitsigns'.refresh()")

  -- Term
  cmd("command! -bang Term terminal<bang> /usr/local/bin/fish")
  cmd("command! -nargs=* T split | Term <args>")
  cmd("command! -nargs=* VT vsplit | Term <args>")

  -- Session
  cmd("command! -nargs=* SS lua require('utils').saveSession(vim.fn.expand('<args>'))")
  cmd("command! -nargs=* -complete=file SR lua require('utils').restoreSession(vim.fn.expand('<args>'))")
  cmd("command! -nargs=* -complete=file SD lua require('utils').deleteSession(vim.fn.expand('<args>'))")

  -- Json format
  cmd("command! Fj %!jq")

  cmd("command! Cd cd %:h")
  cmd("command! Bd bufdo bd")

  cmd('command! -nargs=* W w')
end

return commands
