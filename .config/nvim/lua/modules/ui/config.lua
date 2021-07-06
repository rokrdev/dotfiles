local config = {}

function config.bufferline()
  require('bufferline').setup{
    options = {
      show_buffer_close_icons = false,
      show_close_icon = false,
      separator_style = "thick",
      mappings = false,
      always_show_bufferline = false,
    },
  }
end

function config.lualine()
  require('lualine').setup{
    options = {
      theme = 'tokyonight',
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
  require("nvim-tree.events").on_nvim_tree_ready(function()
    vim.cmd("NvimTreeRefresh")
  end)
end

function config.illuminate()
  vim.g.Illuminate_delay = 500
  vim.g.Illuminate_highlightUnderCursor = 1
  vim.g.Illuminate_ftblacklist = {'NvimTree'}
end

function config.gitsigns()
  if not packer_plugins['plenary.nvim'].loaded then
    vim.cmd [[packadd plenary.nvim]]
  end
  require('gitsigns').setup {
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

function config.theme()

  vim.g.tokyonight_style = "night"
  vim.g.tokyonight_italic_functions = true
  vim.g.tokyonight_italic_comments = true
  vim.g.tokyonight_dark_sidebar = false
  vim.g.tokyonight_dark_float = false
  vim.api.nvim_exec(
    [[
      colorscheme tokyonight
      hi default link EndOfLineSpace Substitute
      match EndOfLineSpace /\s\+$/
    ]],
    false
  )
end

return config
