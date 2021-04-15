local config = {}

local function autopair()
  local remap = vim.api.nvim_set_keymap
  local npairs = require('nvim-autopairs')

  -- skip it, if you use another global object
  _G.MUtils= {}

  vim.g.completion_confirm_key = ""
  MUtils.completion_confirm=function()
    if vim.fn.pumvisible() ~= 0  then
      if vim.fn.complete_info()["selected"] ~= -1 then
        vim.fn["compe#confirm"]()
        return npairs.esc("<c-y>")
      else
        vim.defer_fn(function()
          vim.fn["compe#confirm"]("<cr>")
        end, 20)
        return npairs.esc("<c-n>")
      end
    else
      return npairs.check_break_line_char()
    end
  end

  remap('i' , '<CR>','v:lua.MUtils.completion_confirm()', {expr = true , noremap = true})
end

function config.autopairs()
  require('nvim-autopairs').setup()
  autopair()
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
