local setup = {}
local conf = require('plugins.config')

setup['windwp/nvim-autopairs'] = {
  event = 'VimEnter',
  config = conf.autopairs,
}

-- setup['camspiers/snap'] = {
--   event = 'VimEnter',
--   config = conf.snap,
-- }

setup['nvim-telescope/telescope.nvim'] = {
  event = 'VimEnter',
  config = conf.telescope,
  requires = {
    {'nvim-lua/popup.nvim', opt = true},
    {'nvim-lua/plenary.nvim',opt = true},
    {'nvim-telescope/telescope-fzf-writer.nvim', opt = true},
  }
}

setup['nvim-treesitter/nvim-treesitter'] = {
  event = 'VimEnter',
  config = conf.treesitter
}

setup['tpope/vim-commentary'] = {
  event = 'VimEnter',
}

setup['kyazdani42/nvim-web-devicons'] = {
  event = 'VimEnter',
}

setup['folke/tokyonight.nvim'] = {
  event = 'VimEnter',
  config = conf.theme,
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
