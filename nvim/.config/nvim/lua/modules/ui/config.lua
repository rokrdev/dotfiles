local config = {}

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
    current_line_blame = true,
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
      delay = 1000,
    },
    sign_priority = 6,
    update_debounce = 100,
    status_formatter = nil, -- Use default
    use_decoration_api = true,
    use_internal_diff = true,  -- If luajit is present
  }
end

function config.telescope()
  if not packer_plugins['plenary.nvim'].loaded then
    vim.cmd [[packadd plenary.nvim]]
    vim.cmd [[packadd popup.nvim]]
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
          ["<esc>"] = actions.close,
          ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
        },
      },
      sorting_strategy = 'descending',
      file_previewer = require'telescope.previewers'.vim_buffer_cat.new,
      grep_previewer = require'telescope.previewers'.vim_buffer_vimgrep.new,
      qflist_previewer = require'telescope.previewers'.vim_buffer_qflist.new,
    },
    extensions = {
      fzf = {
        fuzzy = true,                    -- false will only do exact matching
        override_generic_sorter = true,  -- override the generic sorter
        override_file_sorter = true,     -- override the file sorter
        case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
        -- the default case_mode is "smart_case"
      }
    }
  }
  vim.cmd([[packadd cfilter]])
end

function config.bufferline()
  require('bufferline').setup{
    options = {
      show_buffer_close_icons = false,
      show_close_icon = false,
      separator_style = "thick",
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
        {'diagnostics', sources = {'nvim_diagnostic'}, sections = {'error', 'warn'}},
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
    extensions = {
      'nvim-tree',
      'quickfix',
    }
  }
end

function config.tree()
  vim.g["nvim_tree_indent_markers"] = 1
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
  require('nvim-tree').setup {
    disable_netrw       = true,
    hijack_netrw        = true,
    auto_close          = true,
    update_cwd          = true,
    update_focused_file = {
      enable      = true,
      update_cwd  = false,
      ignore_list = {}
    },
    view = {
      width = 30,
      side = 'left',
      auto_resize = true,
    }
  }
  -- require("nvim-tree.events").on_nvim_tree_ready(function()
  --   vim.cmd("NvimTreeRefresh")
  -- end)
end


function config.theme()
  vim.g.tokyonight_transparent = true
  vim.g.tokyonight_transparent_sidebar = true
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
      hi EndOfBuffer ctermfg=11 guifg=#3b4261
      hi VertSplit ctermfg=11 guifg=#3b4261
    ]],
    false
  )
end


function config.alpha()
  local alpha = require("alpha")
  local dashboard = require("alpha.themes.dashboard")

  -- Set header
  dashboard.section.header.val = {
    "                                                     ",
    "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
    "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
    "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
    "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
    "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
    "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
    "                                                     ",
  }

  -- Set menu
  dashboard.section.buttons.val = {
    dashboard.button( "e", "> New file", ":ene<CR>"),
    dashboard.button( "SPC f f", "> Find file", ":Telescope find_files hidden=true<CR>"),
    dashboard.button( "SPC f s", "> Search word", ":Telescope live_grep<CR>"),
    dashboard.button( "SPC f n", "> Directory", ":NnnPicker<CR>"),
    dashboard.button( "SPC f o", "> Recent", ":Telescope oldfiles<CR>"),
    dashboard.button( "SPC f t", "> Tree", ":NvimTreeToggle<CR>"),
    dashboard.button( "SPC f v", "> Settings", ":e $MYVIMRC | :cd %:p:h | split . | wincmd k | pwd<CR>"),
    dashboard.button( "q", "> Quit NVIM", ":qa<CR>"),
  }

  -- Set footer
  --   NOTE: This is currently a feature in my fork of alpha-nvim (opened PR #21, will update snippet if added to main)
  --   To see test this yourself, add the function as a dependecy in packer and uncomment the footer lines
  --   ```init.lua
  --   return require('packer').startup(function()
  --       use 'wbthomason/packer.nvim'
  --       use {
  --           'goolord/alpha-nvim', branch = 'feature/startify-fortune',
  --           requires = {'BlakeJC94/alpha-nvim-fortune'},
  --           config = function() require("config.alpha") end
  --       }
  --   end)
  --   ```
  -- local fortune = require("alpha.fortune")
  -- dashboard.section.footer.val = fortune()

  -- Send config to alpha
  alpha.setup(dashboard.opts)

  -- Disable folding on alpha buffer
  vim.cmd([[
    autocmd FileType alpha setlocal nofoldenable
  ]])
end

function config.nnn()
  require("nnn").setup()
end

return config
