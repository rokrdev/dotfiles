local ui = {}
local conf = require('modules.ui.config')

ui["lukas-reineke/indent-blankline.nvim"] = {
  branch = 'lua',
  opt = true,
  event = 'VimEnter',
  config = conf.indentBlankLine
}

ui["akinsho/nvim-bufferline.lua"] = {
  opt = true,
  event = 'VimEnter',
  config = conf.bufferline
}

ui["hoob3rt/lualine.nvim"] = {
  requires = {'kyazdani42/nvim-web-devicons', opt = true},
  event = 'VimEnter',
  config = conf.lualine
}

ui["norcalli/nvim-colorizer.lua"] = {
  event = 'VimEnter',
  config = conf.colorizer
}

ui["kyazdani42/nvim-tree.lua"] = {
  event = 'VimEnter',
  requires = {'kyazdani42/nvim-web-devicons', opt = true},
  config = conf.tree
}

ui["mhinz/vim-signify"] = {
  event = 'VimEnter',
  config = conf.signify
}

ui["rrethy/vim-illuminate"] = {
  event = 'VimEnter',
  config = conf.illuminate
}

return ui
