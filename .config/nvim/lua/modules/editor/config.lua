local config = {}

function config.autopairs()
  if packer_plugins['nvim-autopairs'] and not packer_plugins['nvim-autopairs'].loaded then
    vim.cmd [[packadd nvim-autopairs]]
  end
  require('nvim-autopairs').setup()

  local remap = vim.api.nvim_set_keymap

  vim.g.completion_confirm_key = ""
end

function config.fzf()
  vim.g.fzf_layout = {
    ['window'] = {
      ['width'] = 0.9,
      ['height'] = 0.9,
      ['border'] = 'rounded',
      ['highlight'] = 'Directory'
    }
  }

  vim.g.fzf_buffers_jump = 1

  vim.g.fzf_commits_log_options = '--graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"'

  vim.g.fzf_commands_expect = 'alt-enter,ctrl-x'

  vim.g.fzf_action = {
    ['ctrl-x'] = 'split',
    ['ctrl-v'] = 'vsplit'
  }
  vim.g.fzf_preview_window = 'right:50%'
  vim.cmd([[packadd cfilter]])
end

function config.scalpel()
  vim.g.ScalpelMap=0
end

return config
