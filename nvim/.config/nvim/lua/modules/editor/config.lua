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

function config.indentline()
  require('indent_blankline').setup {
    show_current_context = true,
    show_current_context_start = true,
    buftype_exclude = {'terminal'},
    filetype_exclude = {'alpha', 'help', 'packer', 'NvimTree'},
  }
end

function config.matchup()
  vim.g.matchup_matchparen_offscreen = {}
end

function config.lightspeed()
  vim.cmd[[
    unmap f
    unmap F
    unmap t
    unmap T
  ]]
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
  vim.g.Illuminate_ftblacklist = {'NvimTree', 'alpha'}
end

function config.colorizer()
  require('colorizer').setup()
end

function config.neogit()
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
    }
  }
  neogit.config.use_magit_keybindings()
end

function config.surround()
  require'surround'.setup { mappings_style = "surround"}
end

return config

