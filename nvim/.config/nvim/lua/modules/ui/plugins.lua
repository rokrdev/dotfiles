local plugins = {}
local conf = require('modules.ui.config')

plugins["mcchrish/nnn.vim"] = {
  cmd = 'NnnPicker',
}

plugins['nvim-telescope/telescope.nvim'] = {
  event = 'VimEnter',
  config = conf.telescope,
  requires = {
    {'nvim-lua/popup.nvim', opt = true},
    {'nvim-lua/plenary.nvim',opt = true},
    {'nvim-telescope/telescope-fzf-writer.nvim', opt = true},
  }
}

plugins['lewis6991/gitsigns.nvim'] = {
  event = {'BufRead','BufNewFile'},
  config = conf.gitsigns,
  requires = {'nvim-lua/plenary.nvim',opt=true}
}

plugins['kyazdani42/nvim-web-devicons'] = {
  event = 'VimEnter',
}

plugins['folke/tokyonight.nvim'] = {
  event = 'VimEnter',
  config = conf.theme,
}

plugins["akinsho/nvim-bufferline.lua"] = {
  event = 'VimEnter',
  config = conf.bufferline,
}

plugins["hoob3rt/lualine.nvim"] = {
  event = 'VimEnter',
  config = conf.lualine,
}

plugins['kyazdani42/nvim-tree.lua'] = {
  cmd = {"NvimTreeToggle", "NvimTreeOpen"},
  requires = {'kyazdani42/nvim-web-devicons', opt=true},
  config = conf.tree,
}

return plugins
