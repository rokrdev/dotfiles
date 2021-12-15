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
    -- show_current_context_start = true,
    buftype_exclude = {'terminal'},
    filetype_exclude = {'alpha', 'help', 'packer', 'NvimTree'},
  }
end

function config.matchup()
  vim.g.matchup_matchparen_offscreen = {}
end

function config.lightspeed()
  require'lightspeed'.setup {
    exit_after_idle_msecs = { labeled = nil, unlabeled = 1000 },
    grey_out_search_area = true,
    highlight_unique_chars = true,
    match_only_the_start_of_same_char_seqs = true,
    jump_on_partial_input_safety_timeout = 400,
  }
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

function config.cursorword()
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

function config.trailspace()
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

function config.neoscroll()
  require('neoscroll').setup({
    -- All these keys will be mapped to their corresponding default scrolling animation
    mappings = {'<C-u>', '<C-d>', '<C-b>', '<C-f>',
    '<C-y>', '<C-e>', 'zt', 'zz', 'zb'},
    hide_cursor = true,          -- Hide cursor while scrolling
    stop_eof = true,             -- Stop at <EOF> when scrolling downwards
    use_local_scrolloff = false, -- Use the local scope of scrolloff instead of the global scope
    respect_scrolloff = false,   -- Stop scrolling when the cursor reaches the scrolloff margin of the file
    cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
    easing_function = nil,        -- Default easing function
    pre_hook = nil,              -- Function to run before the scrolling animation starts
    post_hook = nil,              -- Function to run after the scrolling animation ends
  })
end

return config

