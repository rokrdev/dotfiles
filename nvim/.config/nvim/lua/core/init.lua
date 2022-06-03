local g = vim.g
local api = vim.api

local disable_distribution_plugins= function()
  g.loaded_gzip              = 1
  g.loaded_tar               = 1
  g.loaded_tarPlugin         = 1
  g.loaded_zip               = 1
  g.loaded_zipPlugin         = 1
  g.loaded_getscript         = 1
  g.loaded_getscriptPlugin   = 1
  g.loaded_vimball           = 1
  g.loaded_vimballPlugin     = 1
  g.loaded_matchit           = 1
  g.loaded_matchparen        = 1
  g.loaded_2html_plugin      = 1
  g.loaded_logiPat           = 1
  g.loaded_rrhelper          = 1
  g.loaded_netrw             = 1
  g.loaded_netrwPlugin       = 1
  g.loaded_netrwSettings     = 1
  g.loaded_netrwFileHandlers = 1
  g.spellfile_plugin         = 1
  g.fzf                      = 1
end

local leader_map = function()
  g.mapleader = " "
  api.nvim_set_keymap('n', ' ', '' ,{noremap = true})
  api.nvim_set_keymap('x', ' ', '' ,{noremap = true})
end

local disable_vim_filetype = function()
  g.did_load_filetypes = 0
  g.do_filetype_lua = 1
end

local load_core =function()
  local pack = require('core.pack')
  -- createdir()
  disable_distribution_plugins()
  disable_vim_filetype()
  leader_map()

  pack.ensure_plugins()
  require('core.options')
  require('core.event')
  require('keymap')
  pack.load_compile()
end

load_core()
