local plugins = {}
local conf = require('modules.editor.config')

plugins["norcalli/nvim-colorizer.lua"] = {
  event = 'VimEnter',
  config = conf.colorizer,
}

plugins["rrethy/vim-illuminate"] = {
  event = 'VimEnter',
  setup = conf.illuminate,
}

plugins['windwp/nvim-autopairs'] = {
  event = 'VimEnter',
  config = conf.autopairs,
}

plugins['editorconfig/editorconfig-vim'] = {
  ft = { 'go','vim','rust' }
}

plugins["lukas-reineke/indent-blankline.nvim"] = {
  after = 'tokyonight.nvim',
  config = conf.indentline
}

plugins["ggandor/lightspeed.nvim"] = {
  event = 'VimEnter',
  config = conf.lightspeed
}

plugins['wincent/scalpel'] = {
  event = 'VimEnter',
  setup = conf.scalpel,
}

plugins['haya14busa/vim-asterisk'] = {
  event = 'VimEnter',
  setup = vim.cmd[[let g:asterisk#keeppos = 1]],
}

plugins['machakann/vim-sandwich'] = {
  event = 'VimEnter',
}

plugins['zenobht/vim-multiple-cursors'] = {
  event = 'VimEnter',
  setup = conf.multi,
}

plugins['wellle/targets.vim'] = {
  event = 'VimEnter',
}

plugins['rhysd/accelerated-jk'] = {
  opt = true,
}

plugins['andymass/vim-matchup'] = {
  event = 'VimEnter',
  setup = conf.matchup,
}

plugins['TimUntersberger/neogit'] = {
  cmd = 'Neogit',
  config = conf.neogit,
  requires = {
    {'nvim-lua/plenary.nvim'},
    {'sindrets/diffview.nvim', opt = true},
  }
}

return plugins
