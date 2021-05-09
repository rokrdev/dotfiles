local config = {}

function config.autopairs()
  if packer_plugins['nvim-autopairs'] and not packer_plugins['nvim-autopairs'].loaded then
    vim.cmd [[packadd nvim-autopairs]]
  end
  require('nvim-autopairs').setup()

  local remap = vim.api.nvim_set_keymap

  vim.g.completion_confirm_key = ""
end

-- function config.fzf()
--   require('utils').sourceFzfVim()
--   vim.g.fzf_layout = {
--     ['window'] = {
--       ['width'] = 0.9,
--       ['height'] = 0.9,
--       ['border'] = 'rounded',
--       ['highlight'] = 'Directory'
--     }
--   }

--   vim.g.fzf_buffers_jump = 1

--   vim.g.fzf_commits_log_options = '--graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"'

--   vim.g.fzf_commands_expect = 'alt-enter,ctrl-x'

--   vim.g.fzf_action = {
--     ['ctrl-x'] = 'split',
--     ['ctrl-v'] = 'vsplit'
--   }
--   vim.g.fzf_preview_window = 'right:50%'
-- end

-- function config.fzf_after()
--   vim.cmd([[packadd cfilter]])
-- end

function config.scalpel()
  vim.g.ScalpelMap=0
end

function config.matchup()
  vim.g.matchup_matchparen_offscreen = {}
end

function config.telescope()
  if not packer_plugins['plenary.nvim'].loaded then
    vim.cmd [[packadd plenary.nvim]]
    vim.cmd [[packadd popup.nvim]]
    vim.cmd [[packadd telescope-fzy-native.nvim]]
  end

  local actions = require('telescope.actions')
  require('telescope').setup {
    defaults = {
      vimgrep_arguments = {
        'rg',
        '--color=never',
        '--hidden',
        '--no-heading',
        '--with-filename',
        '--line-number',
        '--column',
        '--smart-case'
      },
      mappings = {
        i = {
          ["<esc>"] = actions.close
        },
      },
      prompt_prefix = '🔭 ',
      prompt_position = 'bottom',
      selection_caret = " ",
      sorting_strategy = 'descending',
      results_width = 0.6,
      file_previewer = require'telescope.previewers'.vim_buffer_cat.new,
      grep_previewer = require'telescope.previewers'.vim_buffer_vimgrep.new,
      qflist_previewer = require'telescope.previewers'.vim_buffer_qflist.new,
    },
    extensions = {
      extensions = {
        fzf = {
          override_generic_sorter = false, -- override the generic sorter
          override_file_sorter = true,     -- override the file sorter
          case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                          -- the default case_mode is "smart_case"
        }
      }
    }
  }
  require('telescope').load_extension('fzf')
end

return config
