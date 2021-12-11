local plugins = {}
local conf = require('modules.lang.config')

plugins['nvim-treesitter/nvim-treesitter'] = {
  config = conf.treesitter
}

plugins['nvim-treesitter/playground'] = {
  cmd = 'TSPlaygroundToggle'
}

plugins['elixir-editors/vim-elixir'] = {
  opt = true,
  ft = {'elixir', 'eelixir'},
}

plugins['JoosepAlviste/nvim-ts-context-commentstring'] = {
  requires = {'nvim-treesitter', 'tpope/vim-commentary'},
}

plugins['nvim-treesitter/nvim-treesitter-textobjects'] = {
  requires = 'nvim-treesitter',
}

plugins['styled-components/vim-styled-components'] = {
  branch = 'main',
  opt = true,
  ft = {'javascript', 'typescript', 'javascriptreact'},
}

plugins['jxnblk/vim-mdx-js'] = {
  opt = true,
  ft = {'mdx'}
}

plugins['iamcco/markdown-preview.nvim'] = {
  opt = true,
  ft = {'markdown'},
  run = 'cd app && yarn install',
  cmd = 'MarkdownPreview'
}

return plugins
