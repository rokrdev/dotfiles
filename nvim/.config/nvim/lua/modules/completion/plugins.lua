local plugins = {}
local conf = require('modules.completion.config')

plugins["neovim/nvim-lspconfig"] = {
  event = 'BufReadPre',
  config = conf.lspconfig
}

plugins["hrsh7th/nvim-compe"] = {
  event = 'InsertCharPre',
  config = conf.plugins
}

plugins["hrsh7th/vim-vsnip"] = {
  event = 'InsertCharPre',
  config = conf.vsnip
}

plugins["hrsh7th/vim-vsnip-integ"] = {
  event = 'InsertCharPre',
}

return plugins
