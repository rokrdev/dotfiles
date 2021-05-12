local editor = {}
local conf = require('modules.editor.config')

editor['windwp/nvim-autopairs'] = {
  event = 'VimEnter',
  config = conf.autopairs,
}

-- editor["junegunn/fzf.vim"] = {
--   event = 'VimEnter',
--   setup = conf.fzf,
--   config = conf.fzf_after,
-- }

editor['nvim-telescope/telescope.nvim'] = {
  event = 'VimEnter',
  setup = conf.fzf,
  config = conf.telescope,
  requires = {
    {'nvim-lua/popup.nvim', opt = true},
    {'nvim-lua/plenary.nvim',opt = true},
    {'nvim-telescope/telescope-fzf-writer.nvim', opt = true},
  }
}

editor['editorconfig/editorconfig-vim'] = {
  ft = { 'go','vim','rust' }
}

editor["mcchrish/nnn.vim"] = {
  cmd = 'NnnPicker',
}

editor["justinmk/vim-sneak"] = {
  event = {'BufReadPre','BufNewFile'},
}

editor['wincent/scalpel'] = {
  event = {'BufReadPre','BufNewFile'},
  setup = conf.scalpel,
}

editor['haya14busa/vim-asterisk'] = {
  event = {'BufReadPre','BufNewFile'},
  setup = vim.cmd[[let g:asterisk#keeppos = 1]],
}

editor['machakann/vim-sandwich'] = {
  event = {'BufReadPre','BufNewFile'},
}

editor['wellle/targets.vim'] = {
  event = {'BufReadPre','BufNewFile'},
}

editor['rhysd/accelerated-jk'] = {
  opt = true,
}

editor['andymass/vim-matchup'] = {
  event = {'BufReadPre','BufNewFile'},
  opt = true,
  setup = conf.matchup,
}

return editor
