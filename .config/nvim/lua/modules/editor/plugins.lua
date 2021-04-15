local editor = {}
local conf = require('modules.editor.config')

editor['windwp/nvim-autopairs'] = {
  event = 'InsertCharPre',
  config = conf.autopairs
}

editor["junegunn/fzf.vim"] = {
  event = 'VimEnter',
  config = conf.fzf
}

editor["mcchrish/nnn.vim"] = {
  cmd = 'NnnPicker',
}

editor["justinmk/vim-sneak"] = {
  event = {'BufReadPre','BufNewFile'},
}

editor['wincent/scalpel'] = {
  event = {'BufReadPre','BufNewFile'},
  config = conf.scalpel
}

editor['rhysd/git-messenger.vim'] = {
  event = {'BufReadPre','BufNewFile'},
  cmd = 'GitMessenger'
}

editor['machakann/vim-sandwich'] = {
  event = {'BufReadPre','BufNewFile'},
}

return editor
