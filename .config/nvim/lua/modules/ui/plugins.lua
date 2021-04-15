local ui = {}
local conf = require('modules.ui.config')

ui["lukas-reineke/indent-blankline.nvim"] = {
  branch = 'lua',
  event = 'BufRead',
  config = conf.indentBlankLine
}

ui["akinsho/nvim-bufferline.lua"] = {
  config = conf.bufferline
}

ui["hoob3rt/lualine.nvim"] = {
  requires = 'kyazdani42/nvim-web-devicons',
  config = conf.lualine
}

ui["norcalli/nvim-colorizer.lua"] = {
  event = {'BufRead','BufNewFile'},
  config = conf.colorizer
}

ui["kyazdani42/nvim-tree.lua"] = {
  cmd = {'NvimTreeToggle','NvimTreeOpen'},
  requires = 'kyazdani42/nvim-web-devicons',
  config = conf.tree
}

ui["mhinz/vim-signify"] = {
  event = {'BufRead','BufNewFile'},
  config = conf.signify
}

ui["rrethy/vim-illuminate"] = {
  event = {'BufRead','BufNewFile'},
  config = conf.illuminate
}

return ui
