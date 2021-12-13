local plugins = {}
local conf = require('modules.editor.config')

plugins["norcalli/nvim-colorizer.lua"] = {
  event = 'VimEnter',
  config = conf.colorizer,
}

plugins["zenobht/cursorword.nvim"] = {
  event = 'VimEnter',
  config = conf.cursorword,
}

plugins["zenobht/trailspace.nvim"] = {
  event = 'VimEnter',
  config = conf.trailspace,
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

plugins['kevinhwang91/nvim-hlslens'] = {
  event = 'VimEnter',
}

plugins['blackCauldron7/surround.nvim'] = {
  event = 'VimEnter',
  config = conf.surround,
}

plugins['zenobht/vim-multiple-cursors'] = {
  event = 'VimEnter',
  setup = conf.multi,
}

plugins['wellle/targets.vim'] = {
  event = 'VimEnter',
}

plugins['karb94/neoscroll.nvim'] = {
  event = 'VimEnter',
  config = conf.neoscroll,
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
