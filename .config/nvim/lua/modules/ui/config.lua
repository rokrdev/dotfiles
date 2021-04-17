local config = {}

function config.indentBlankLine()
  vim.g.indent_blankline_filetype_exclude = { 'NvimTree' }
  vim.g.indent_blankline_char = '│'
  vim.g.indent_blankline_use_treesitter = true
  -- vim.g.indent_blankline_show_current_context = true
end

function config.bufferline()
  require('bufferline').setup{
    options = {
      show_buffer_close_icons = false,
      show_close_icon = false,
      separator_style = "thick",
      mappings = false,
    },
    highlights = require('theme').getBufferlineTheme()
  }
end

function config.lualine()
  require('lualine').setup{
    options = {
      theme = require('theme').getLualineTheme(),
      icons_enabled = true,
      component_separators = '',
      section_separators = ''
    },
    sections = {
      lualine_a = { 'mode' },
      lualine_b = { 'branch' },
      lualine_c = { 'filename', 'diff' },
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
  require"nvim-tree".on_enter()
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

return config
