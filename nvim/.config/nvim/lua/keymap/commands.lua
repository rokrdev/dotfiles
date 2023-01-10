local cmd = vim.cmd
local commands = {}

function commands.setup()
  cmd("command! Gcd lua require('keymap.utils').goToRoot()")
  cmd("command! Tcc lua require('keymap.utils').toggleColorColumn()")
  cmd("command! Scratch lua require('keymap.utils').scratchGenerator()")

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
  cmd("command! -nargs=* SS lua require('keymap.utils').saveSession(vim.fn.expand('<args>'))")
  cmd("command! -nargs=* -complete=file SR lua require('keymap.utils').restoreSession(vim.fn.expand('<args>'))")
  cmd("command! -nargs=* -complete=file SD lua require('keymap.utils').deleteSession(vim.fn.expand('<args>'))")

  -- Json format
  cmd("command! Jq %!jq")

  cmd("command! Cd cd %:h")
  cmd("command! Bd bufdo bd")

  cmd('command! -nargs=* WQ wq')
  cmd('command! -nargs=* Wq wq')
  cmd('command! -nargs=* W w')
  cmd('command! -nargs=* Q q')

  cmd("command! Reload lua require('core.pack').reload_config()")
end

return commands
