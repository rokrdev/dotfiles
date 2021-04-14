local config = {}

function config.autopairs()
  require('nvim-autopairs').setup()
  require('autopair')
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

return config
