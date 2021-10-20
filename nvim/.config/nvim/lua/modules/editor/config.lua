local config = {}

function config.autopairs()
  if packer_plugins['nvim-autopairs'] and not packer_plugins['nvim-autopairs'].loaded then
    vim.cmd [[packadd nvim-autopairs]]
  end
  require('nvim-autopairs').setup()

  local remap = vim.api.nvim_set_keymap

  vim.g.completion_confirm_key = ""
end

function config.scalpel()
  vim.g.ScalpelMap=0
end

function config.matchup()
  vim.g.matchup_matchparen_offscreen = {}
end

function config.sneak()
  vim.g["sneak#use_ic_scs"] = 1
end

function config.multi()
  vim.g.multi_cursor_use_default_mapping = 0
  vim.g.multi_cursor_start_word_key      = '<M-n>'
  vim.g.multi_cursor_start_key           = 'g<M-n>'
  vim.g.multi_cursor_next_key            = '<M-n>'
  vim.g.multi_cursor_prev_key            = '<M-p>'
  vim.g.multi_cursor_skip_key            = '<M-x>'
  vim.g.multi_cursor_quit_key            = '<Esc>'
end

function config.illuminate()
  vim.g.Illuminate_delay = 500
  vim.g.Illuminate_highlightUnderCursor = 1
  vim.g.Illuminate_ftblacklist = {'NvimTree'}
end

function config.colorizer()
  require('colorizer').setup()
end

return config

