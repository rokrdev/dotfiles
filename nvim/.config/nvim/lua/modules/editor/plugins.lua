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

-- plugins['tpope/vim-commentary'] = {
--   event = 'VimEnter',
-- }

plugins['editorconfig/editorconfig-vim'] = {
  ft = { 'go','vim','rust' }
}

-- plugins["justinmk/vim-sneak"] = {
--   event = {'BufReadPre','BufNewFile'},
--   setup = conf.sneak
-- }

plugins["lukas-reineke/indent-blankline.nvim"] = {
  after = 'tokyonight.nvim',
  config = conf.indentline
}

plugins["ggandor/lightspeed.nvim"] = {
  event = {'BufReadPre','BufNewFile'},
  config = conf.lightspeed
}

plugins['wincent/scalpel'] = {
  event = {'BufReadPre','BufNewFile'},
  setup = conf.scalpel,
}

plugins['haya14busa/vim-asterisk'] = {
  event = {'BufReadPre','BufNewFile'},
  setup = vim.cmd[[let g:asterisk#keeppos = 1]],
}

plugins['machakann/vim-sandwich'] = {
  event = {'BufReadPre','BufNewFile'},
}

plugins['zenobharat/vim-multiple-cursors'] = {
  event = {'BufReadPre','BufNewFile'},
  setup = conf.multi,
}

plugins['wellle/targets.vim'] = {
  event = {'BufReadPre','BufNewFile'},
}

plugins['rhysd/accelerated-jk'] = {
  opt = true,
}

plugins['andymass/vim-matchup'] = {
  event = {'BufReadPre','BufNewFile'},
  setup = conf.matchup,
}

plugins['TimUntersberger/neogit'] = {
  cmd = 'Neogit',
  config = conf.neogit,
  requires = {
    {'nvim-lua/plenary.nvim', opt = true},
    {'sindrets/diffview.nvim', opt = true},
  }
}

return plugins
