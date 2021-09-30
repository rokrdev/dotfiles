local setup = {}
local conf = require('plugins.config')

setup["neovim/nvim-lspconfig"] = {
  event = 'BufReadPre',
  config = conf.lspconfig
}

setup["hrsh7th/nvim-compe"] = {
  event = 'InsertCharPre',
  config = conf.setup
}

setup["hrsh7th/vim-vsnip"] = {
  event = 'InsertCharPre',
  config = conf.vsnip
}

setup["hrsh7th/vim-vsnip-integ"] = {
  event = 'InsertCharPre',
}


setup['windwp/nvim-autopairs'] = {
  event = 'VimEnter',
  config = conf.autopairs,
}

setup['camspiers/snap'] = {
  event = 'VimEnter',
  config = conf.snap,
}

-- setup['nvim-telescope/telescope.nvim'] = {
--   cmd = 'Telescope',
--   config = conf.telescope,
--   requires = {
--     {'nvim-lua/popup.nvim', opt = true},
--     {'nvim-lua/plenary.nvim',opt = true},
--     {'nvim-telescope/telescope-fzf-writer.nvim', opt = true},
--   }
-- }

setup['editorconfig/editorconfig-vim'] = {
  ft = { 'go','vim','rust' }
}

setup["mcchrish/nnn.vim"] = {
  cmd = 'NnnPicker',
}

-- setup["easymotion/vim-easymotion"] = {
--   event = {'BufReadPre','BufNewFile'},
--   setup = conf.easymotion
-- }

setup["justinmk/vim-sneak"] = {
  event = {'BufReadPre','BufNewFile'},
  setup = conf.sneak
}

setup['wincent/scalpel'] = {
  event = {'BufReadPre','BufNewFile'},
  setup = conf.scalpel,
}

setup['haya14busa/vim-asterisk'] = {
  event = {'BufReadPre','BufNewFile'},
  setup = vim.cmd[[let g:asterisk#keeppos = 1]],
}

setup['machakann/vim-sandwich'] = {
  event = {'BufReadPre','BufNewFile'},
}

setup['1bharat/vim-multiple-cursors'] = {
  event = {'BufReadPre','BufNewFile'},
  setup = conf.multi,
}

setup['wellle/targets.vim'] = {
  event = {'BufReadPre','BufNewFile'},
}

setup['rhysd/accelerated-jk'] = {
  opt = true,
}

setup['andymass/vim-matchup'] = {
  event = {'BufReadPre','BufNewFile'},
  setup = conf.matchup,
}


setup['nvim-treesitter/nvim-treesitter'] = {
  event = 'VimEnter',
  config = conf.treesitter
}

setup['nvim-treesitter/playground'] = {
  cmd = 'TSPlaygroundToggle'
}

setup['elixir-editors/vim-elixir'] = {
  opt = true,
  ft = {'elixir', 'eelixir'},
}

setup['tpope/vim-commentary'] = {
  event = 'VimEnter',
}

setup['JoosepAlviste/nvim-ts-context-commentstring'] = {
  after = 'nvim-treesitter',
}

-- setup['nvim-treesitter/nvim-treesitter-textobjects'] = {
--   after = 'nvim-treesitter'
-- }

setup['styled-components/vim-styled-components'] = {
  branch = 'main',
  opt = true,
  ft = {'javascript', 'typescript', 'javascriptreact'},
}

setup['jxnblk/vim-mdx-js'] = {
  opt = true,
  ft = {'mdx'}
}

setup['iamcco/markdown-preview.nvim'] = {
  opt = true,
  ft = {'markdown'},
  run = 'cd app && yarn install',
  cmd = 'MarkdownPreview'
}

setup['kyazdani42/nvim-web-devicons'] = {
  event = 'VimEnter',
}

setup['folke/tokyonight.nvim'] = {
  event = 'VimEnter',
  config = conf.theme,
}

setup['lewis6991/gitsigns.nvim'] = {
  event = {'BufRead','BufNewFile'},
  config = conf.gitsigns,
  requires = {'nvim-lua/plenary.nvim',opt=true}
}

setup["akinsho/nvim-bufferline.lua"] = {
  event = 'VimEnter',
  config = conf.bufferline,
}

setup["hoob3rt/lualine.nvim"] = {
  event = 'VimEnter',
  config = conf.lualine,
}

setup["norcalli/nvim-colorizer.lua"] = {
  event = 'VimEnter',
  config = conf.colorizer,
}

setup['kyazdani42/nvim-tree.lua'] = {
  -- cmd = {"NvimTreeToggle", "NvimTreeOpen"},
  event = 'VimEnter',
  requires = {'kyazdani42/nvim-web-devicons', opt=true},
  config = conf.tree,
}

setup["rrethy/vim-illuminate"] = {
  event = 'VimEnter',
  setup = conf.illuminate,
}

return setup
