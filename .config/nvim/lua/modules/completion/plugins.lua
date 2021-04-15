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
  event = 'VimEnter',
  config = conf.vsnip
}

completion["hrsh7th/vim-vsnip-integ"] = {
  event = 'VimEnter',
}


return completion
