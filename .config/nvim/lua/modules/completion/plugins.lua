local completion = {}
local conf = require('modules.completion.config')

completion["neovim/nvim-lspconfig"] = {
  event = 'BufReadPre',
  config = conf.lspconfig
}

completion["hrsh7th/nvim-compe"] = {
  event = 'InsertCharPre',
  config = conf.completion
}

completion["hrsh7th/vim-vsnip"] = {
  event = 'InsertCharPre',
  config = conf.vsnip
}

completion["hrsh7th/vim-vsnip-integ"] = {
  event = 'InsertCharPre',
}


return completion
