local editor = {}
local conf = require('modules.editor.config')

editor['windwp/nvim-autopairs'] = {
  event = "VimEnter",
  config = conf.autopairs
}

editor["junegunn/fzf.vim"] = {
  opt = true,
  event = 'VimEnter',
  config = conf.fzf
}

editor["mcchrish/nnn.vim"] = {
  opt = true,
  event = 'VimEnter',
}

editor["justinmk/vim-sneak"] = {
  opt = true,
  event = 'VimEnter',
}

return editor
