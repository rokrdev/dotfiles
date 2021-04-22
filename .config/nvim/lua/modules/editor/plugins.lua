local editor = {}
local conf = require('modules.editor.config')

editor['windwp/nvim-autopairs'] = {
  event = 'VimEnter',
  config = conf.autopairs,
}

editor["junegunn/fzf.vim"] = {
  event = 'VimEnter',
  config = conf.fzf,
}

editor["mcchrish/nnn.vim"] = {
  cmd = 'NnnPicker',
}

editor["justinmk/vim-sneak"] = {
  event = {'BufReadPre','BufNewFile'},
}

editor['wincent/scalpel'] = {
  event = {'BufReadPre','BufNewFile'},
  config = conf.scalpel,
}

editor['machakann/vim-sandwich'] = {
  event = {'BufReadPre','BufNewFile'},
}

editor['rhysd/accelerated-jk'] = {
  opt = true,
}

editor['andymass/vim-matchup'] = {
  event = {'BufReadPre','BufNewFile'},
  opt = true,
  config = conf.matchup,
}

return editor
