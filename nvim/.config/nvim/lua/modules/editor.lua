local plugins = {}

plugins["norcalli/nvim-colorizer.lua"] = {
  event = 'VimEnter',
  config = function ()
    require('colorizer').setup()
  end
}

plugins["zenobht/cursorword.nvim"] = {
  event = 'VimEnter',
  config = function ()
    vim.g.cursorword_blacklist_filetype = {
      'NvimTree',
      'alpha',
      'term',
      'NeogitCommitMessage',
      'NeogitStatus'
    }
    require('cursorword').setup({
      delay = 250,
    })
  end
}

plugins["zenobht/trailspace.nvim"] = {
  event = 'VimEnter',
  config = function ()
    vim.g.trailspace_blacklist_filetype = {
      'NvimTree',
      'alpha',
      'term',
      'NeogitCommitMessage',
      'NeogitStatus'
    }
    require('trailspace').setup({
      only_in_normal_buffers = true,
    })
  end
}

plugins['windwp/nvim-autopairs'] = {
  event = 'VimEnter',
  config = function ()
    if packer_plugins['nvim-autopairs'] and not packer_plugins['nvim-autopairs'].loaded then
      vim.cmd [[packadd nvim-autopairs]]
    end
    require('nvim-autopairs').setup()

    local remap = vim.api.nvim_set_keymap

    vim.g.completion_confirm_key = ""
  end
}

plugins['editorconfig/editorconfig-vim'] = {
  ft = { 'go','vim','rust', 'kotlin', 'java' }
}

plugins["lukas-reineke/indent-blankline.nvim"] = {
  after = 'tokyonight.nvim',
  config = function ()
    require('indent_blankline').setup {
      show_current_context = true,
      -- show_current_context_start = true,
      buftype_exclude = {'terminal'},
      filetype_exclude = {'alpha', 'help', 'packer', 'NvimTree'},
    }
  end
}

-- plugins['rlane/pounce.nvim'] = {
--   event = 'VimEnter',
--   config = function ()
--     require'pounce'.setup{
--       accept_keys = "JFKDLSAHGNUVRBYTMICEOXWPQZ",
--       accept_best_key = "<enter>",
--       multi_window = true,
--       debug = false,
--     }
--   end
-- }
plugins['ggandor/lightspeed.nvim'] = {
  event = 'VimEnter',
  config = function ()
    require'lightspeed'.setup {
      ignore_case = true,
      exit_after_idle_msecs = { unlabeled = 1000, labeled = nil },
      --- s/x ---
      jump_to_unique_chars = false,
      match_only_the_start_of_same_char_seqs = true,
      force_beacons_into_match_width = false,
      -- Display characters in a custom way in the highlighted matches.
      substitute_chars = { ['\r'] = '¬', },
      -- These keys are captured directly by the plugin at runtime.
      special_keys = {
        next_match_group = '<space>',
        prev_match_group = '<tab>',
      },
      --- f/t ---
      limit_ft_matches = 4,
      repeat_ft_with_target_char = false,
    }
  end
}

plugins['wincent/scalpel'] = {
  event = 'VimEnter',
  setup = function ()
    vim.g.ScalpelMap=0
  end
}

plugins['kevinhwang91/nvim-hlslens'] = {
  event = 'VimEnter',
}

plugins['ur4ltz/surround.nvim'] = {
  event = 'VimEnter',
  config = function ()
    require'surround'.setup { mappings_style = "surround"}
  end
}

plugins['wellle/targets.vim'] = {
  event = 'VimEnter',
}

plugins['andymass/vim-matchup'] = {
  event = 'VimEnter',
  setup = function ()
    vim.g.matchup_matchparen_offscreen = {}
  end
}

plugins['TimUntersberger/neogit'] = {
  cmd = 'Neogit',
  requires = {
    {'nvim-lua/plenary.nvim'},
    {'sindrets/diffview.nvim', opt = true},
  },
  config = function ()
    if packer_plugins['diffview.nvim'] and not packer_plugins['diffview.nvim'].loaded then
      vim.cmd [[packadd diffview.nvim]]
    end
    local neogit = require'neogit'
    neogit.setup {
      disable_signs = false,
      disable_hint = false,
      disable_context_highlighting = false,
      disable_commit_confirmation = false,
      auto_refresh = true,
      disable_builtin_notifications = false,
      use_magit_keybindings = true,
      commit_popup = {
        kind = "split",
      },
      -- Change the default way of opening neogit
      kind = "tab",
      -- customize displayed signs
      signs = {
        -- { CLOSED, OPENED }
        section = { ">", "v" },
        item = { ">", "v" },
        hunk = { "", "" },
      },
      integrations = {
        diffview = true,
      },
      -- override/add mappings
      mappings = {
        -- modify status buffer mappings
        status = {
          -- Adds a mapping with "B" as key that does the "BranchPopup" command
          ["B"] = "BranchPopup",
        }
      },
    }
  end
}

return plugins
