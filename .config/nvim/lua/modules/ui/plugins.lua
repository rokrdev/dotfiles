local ui = {}
local conf = require('modules.ui.config')

ui['kyazdani42/nvim-web-devicons'] = {
  event = 'VimEnter',
}

ui['~/.config/midnight-owl.nvim'] = {
  event = 'VimEnter',
  -- config = conf.theme,
}

ui['folke/tokyonight.nvim'] = {
  event = 'VimEnter',
  config = conf.theme,
}

ui["lukas-reineke/indent-blankline.nvim"] = {
  event = {'BufRead','BufNewFile'},
  branch = 'lua',
  config = conf.indentBlankLine,
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
  cmd = {'NvimTreeToggle','NvimTreeOpen'},
  config = conf.tree,
}

ui["rrethy/vim-illuminate"] = {
  event = 'VimEnter',
  setup = conf.illuminate,
}

return ui
