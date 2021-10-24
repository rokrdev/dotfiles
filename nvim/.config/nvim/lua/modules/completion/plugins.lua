local plugins = {}
local conf = require('modules.completion.config')

plugins["neovim/nvim-lspconfig"] = {
  requires = 'hrsh7th/cmp-nvim-lsp',
  config = conf.lspconfig,
}

plugins["hrsh7th/nvim-cmp"] = {
  config = conf.completion,
}

plugins["hrsh7th/cmp-buffer"] = {
  requires = 'hrsh7th/nvim-cmp',
}

plugins["hrsh7th/cmp-nvim-lsp"] = {
  requires = 'hrsh7th/nvim-cmp',
}

plugins["hrsh7th/cmp-vsnip"] = {
  requires = 'hrsh7th/nvim-cmp',
}

plugins["hrsh7th/vim-vsnip"] = {
  event = 'InsertCharPre',
  config = conf.vsnip,
}

plugins["hrsh7th/vim-vsnip-integ"] = {
  event = 'InsertCharPre',
}

return plugins
