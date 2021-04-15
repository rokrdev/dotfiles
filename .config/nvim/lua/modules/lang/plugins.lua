local lang = {}
local conf = require('modules.lang.config')

lang['nvim-treesitter/nvim-treesitter'] = {
  event = 'VimEnter',
  run = ':TSUpdate',
  config = conf.treesitter
}

lang['tpope/vim-commentary'] = {
  event = 'VimEnter',
}

lang['JoosepAlviste/nvim-ts-context-commentstring'] = {
  event = 'VimEnter',
}

lang['elixir-editors/vim-elixir'] = {
  ft = {'elixir', 'exs'},
}

lang['styled-components/vim-styled-components'] = {
  branch = 'main',
  ft = {'javascript', 'typescript', 'javascriptreact'},
}

lang['dag/vim-fish'] = {
  ft = {'fish'}
}

lang['jxnblk/vim-mdx-js'] = {
  ft = {'mdx'}
}

lang['iamcco/markdown-preview.nvim'] = {
  ft = {'markdown'},
  run = 'cd app && yarn install',
  cmd = 'MarkdownPreview'
}

return lang

