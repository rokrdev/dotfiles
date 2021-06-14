local ui = {}
local conf = require('modules.ui.config')

ui['kyazdani42/nvim-web-devicons'] = {
  event = 'VimEnter',
}

ui['folke/tokyonight.nvim'] = {
  event = 'VimEnter',
  config = conf.theme,
}

ui['lewis6991/gitsigns.nvim'] = {
  event = {'BufRead','BufNewFile'},
  config = conf.gitsigns,
  requires = {'nvim-lua/plenary.nvim',opt=true}
}

ui["akinsho/nvim-bufferline.lua"] = {
  event = 'VimEnter',
  config = conf.bufferline,
}

ui["hoob3rt/lualine.nvim"] = {
  event = 'VimEnter',
  config = conf.lualine,
}

ui["norcalli/nvim-colorizer.lua"] = {
  event = 'VimEnter',
  config = conf.colorizer,
}

ui['kyazdani42/nvim-tree.lua'] = {
  event = 'VimEnter',
  config = conf.tree,
}

ui["rrethy/vim-illuminate"] = {
  event = 'VimEnter',
  setup = conf.illuminate,
}

return ui
