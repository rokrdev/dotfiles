local completion = {}
local conf = require('modules.completion.config')

completion["neovim/nvim-lspconfig"] = {
  event = 'VimEnter',
  config = conf.lspconfig
}

completion["hrsh7th/nvim-compe"] = {
  event = 'VimEnter',
  config = conf.completion
}

completion["hrsh7th/vim-vsnip"] = {
  requires = {'hrsh7th/vim-vsnip-integ', opt = true},
  event = 'VimEnter',
  config = conf.vsnip
}

return completion
