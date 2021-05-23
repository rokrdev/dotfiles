local lang = {}
local conf = require('modules.lang.config')

lang['nvim-treesitter/nvim-treesitter'] = {
  after = 'telescope.nvim',
  config = conf.treesitter
}

lang['elixir-editors/vim-elixir'] = {
  opt = true,
  ft = {'elixir', 'eelixir'},
}

lang['tpope/vim-commentary'] = {
  event = 'VimEnter',
}

lang['JoosepAlviste/nvim-ts-context-commentstring'] = {
  after = 'nvim-treesitter',
}

lang['nvim-treesitter/nvim-treesitter-textobjects'] = {
  after = 'nvim-treesitter'
}

lang['styled-components/vim-styled-components'] = {
  branch = 'main',
  opt = true,
  ft = {'javascript', 'typescript', 'javascriptreact'},
}

lang['jxnblk/vim-mdx-js'] = {
  opt = true,
  ft = {'mdx'}
}

lang['iamcco/markdown-preview.nvim'] = {
  opt = true,
  ft = {'markdown'},
  run = 'cd app && yarn install',
  cmd = 'MarkdownPreview'
}

return lang

