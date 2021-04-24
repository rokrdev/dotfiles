local config = {}

function config.startify()
  vim.g.startify_lists = {}
  vim.g.startify_fortune_use_unicode = true
end

function config.indentBlankLine()
  vim.g.indent_blankline_filetype_exclude = { 'NvimTree' }
  vim.g.indent_blankline_char = '│'
  vim.g.indent_blankline_use_treesitter = true
  -- vim.g.indent_blankline_show_current_context = true
  vim.g.indent_blankline_filetype_exclude = {
    "startify",
    "log",
    "gitcommit",
    "packer",
    "markdown",
    "json",
    "txt",
    "NvimTree",
    "git",
    "undotree",
    "" -- for all buffers without a file type
  }
  vim.g.indent_blankline_buftype_exclude = {"terminal", "nofile"}
end

function config.bufferline()
  require('bufferline').setup{
    options = {
      show_buffer_close_icons = false,
      show_close_icon = false,
      separator_style = "thick",
      mappings = false,
    },
    highlights = require('midnight-owl').getBufferlineTheme()
  }
end

function config.lualine()
  require('lualine').setup{
    options = {
      theme = require('midnight-owl').getLualineTheme(),
      icons_enabled = true,
      component_separators = '',
      section_separators = ''
    },
    sections = {
      lualine_a = { 'mode' },
      lualine_b = { 'branch' },
      lualine_c = {
        'filename',
        {'diagnostics', sources = {'nvim_lsp'}, sections = {'error', 'warn'}},
        'diff',
      },
      lualine_x = { 'encoding', 'fileformat', 'filetype' },
      lualine_y = { 'progress' },
      lualine_z = { 'location' },
    },
    inactive_sections = {
      lualine_a = {  },
      lualine_b = { 'branch' },
      lualine_c = { 'filename' },
      lualine_x = {  },
      lualine_y = {  },
      lualine_z = { 'location' }
    },
    extensions = { 'fzf' }
  }
end

function config.colorizer()
  require('colorizer').setup()
end

function config.tree()
  vim.g["nvim_tree_indent_markers"] = 1
  vim.g["nvim_tree_follow"] = 1
  vim.g["nvim_tree_auto_close"] = 1
  vim.g["nvim_tree_width_allow_resize"] = 1
  vim.g["nvim_tree_side"] = "left"
  vim.g.nvim_tree_icons = {
    default =  '',
    symlink =  '',
    git = {
      unstaged = "✚",
      staged =  "✚",
      unmerged =  "≠",
      renamed =  "≫",
      untracked = "★",
    },
  }
  require'nvim-tree.events'.on_nvim_tree_ready(function ()
    vim.cmd("NvimTreeRefresh")
  end)
end

function config.signify()
  vim.g.signify_sign_add = '│'
  vim.g.signify_sign_change = '│'
  vim.g.signify_sign_delete = '│'
end

function config.illuminate()
  vim.g.Illuminate_delay = 500
  vim.g.Illuminate_highlightUnderCursor = 1
  vim.g.Illuminate_ftblacklist = {'NvimTree'}
end

function config.gitsigns()
  require('gitsigns').setup {
    signs = {
      add          = {hl = 'SignifySignAdd'   , text = '│', numhl='GitSignsAddNr'   , linehl='GitSignsAddLn'},
      change       = {hl = 'SignifySignChange', text = '│', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
      delete       = {hl = 'SignifySignDelete', text = '_', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
      topdelete    = {hl = 'SignifySignDelete', text = '‾', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
      changedelete = {hl = 'SignifySignChange', text = '~', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
    },
    numhl = false,
    linehl = false,
    keymaps = {
      -- Default keymap options
      noremap = true,
      buffer = true,

      -- ['n ]c'] = { expr = true, "&diff ? ']c' : '<cmd>lua require\"gitsigns\".next_hunk()<CR>'"},
      -- ['n [c'] = { expr = true, "&diff ? '[c' : '<cmd>lua require\"gitsigns\".prev_hunk()<CR>'"},

      -- ['n <leader>hs'] = '<cmd>lua require"gitsigns".stage_hunk()<CR>',
      -- ['n <leader>hu'] = '<cmd>lua requiregitsigns".undo_stage_hunk()<CR>',
      -- ['n <leader>hr'] = '<cmd>lua require"gitsigns".reset_hunk()<CR>',
      -- ['n <leader>hR'] = '<cmd>lua require"gitsigns".reset_buffer()<CR>',
      -- ['n <leader>hp'] = '<cmd>lua require"gitsigns".preview_hunk()<CR>',
      ['n <leader>g;'] = '<cmd>lua require"gitsigns".blame_line()<CR>',

      -- -- Text objects
      -- ['o ih'] = ':<C-U>lua require"gitsigns".select_hunk()<CR>',
      -- ['x ih'] = ':<C-U>lua require"gitsigns".select_hunk()<CR>'
    },
    watch_index = {
      interval = 1000
    },
    current_line_blame = false,
    sign_priority = 6,
    update_debounce = 100,
    status_formatter = nil, -- Use default
    use_decoration_api = true,
    use_internal_diff = true,  -- If luajit is present
  }
end

function config.midnightOwl()
  vim.api.nvim_exec(
    [[
      colorscheme midnight-owl
      match EndOfLineSpace / \\+$/
    ]],
    false
  )
end

return config
