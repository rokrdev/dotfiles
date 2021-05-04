local editor = {}
local conf = require('modules.editor.config')

editor['windwp/nvim-autopairs'] = {
  event = 'VimEnter',
  config = conf.autopairs,
}

editor["junegunn/fzf.vim"] = {
  event = 'VimEnter',
  setup = conf.fzf,
  config = conf.fzf_after,
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
