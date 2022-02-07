local plugins = {}

plugins["luukvbaal/nnn.nvim"] = {
  cmd = 'NnnPicker',
  config = function ()
    local builtin = require("nnn").builtin
    require("nnn").setup({
      mappings = {
        { "<C-t>", builtin.open_in_tab },       -- open file(s) in tab
        { "<C-s>", builtin.open_in_split },     -- open file(s) in split
        { "<C-v>", builtin.open_in_vsplit },    -- open file(s) in vertical split
        { "<C-p>", builtin.open_in_preview },   -- open file in preview split keeping nnn focused
        { "<C-y>", builtin.copy_to_clipboard }, -- copy file(s) to clipboard
        { "<C-w>", builtin.cd_to_path },        -- cd to file directory
        { "<C-e>", builtin.populate_cmdline },  -- populate cmdline (:) with file(s)
      }
    })
  end
}

plugins['nvim-telescope/telescope.nvim'] = {
  event = 'VimEnter',
  requires = {
    {'nvim-lua/popup.nvim'},
    {'nvim-lua/plenary.nvim'},
    {'nvim-telescope/telescope-fzf-native.nvim', run = 'make'},
  },
  config = function ()
    if not packer_plugins['plenary.nvim'].loaded then
      vim.cmd [[packadd plenary.nvim]]
      vim.cmd [[packadd popup.nvim]]
    end

    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')
    local telescope_custom_actions = {}

    function telescope_custom_actions._multiopen(prompt_bufnr, open_cmd)
        local picker = action_state.get_current_picker(prompt_bufnr)
        local selected_entry = action_state.get_selected_entry()
        local num_selections = #picker:get_multi_selection()
        if not num_selections or num_selections <= 1 then
            actions.add_selection(prompt_bufnr)
        end
        actions.send_selected_to_qflist(prompt_bufnr)
        vim.cmd("silent cfdo " .. open_cmd)
    end

    function telescope_custom_actions.multi_selection_open(prompt_bufnr)
        telescope_custom_actions._multiopen(prompt_bufnr, "edit")
    end

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
            ["<TAB>"] = actions.toggle_selection,
            ["<CR>"] = telescope_custom_actions.multi_selection_open,
          },
        },
        sorting_strategy = 'descending',
        file_previewer = require'telescope.previewers'.vim_buffer_cat.new,
        grep_previewer = require'telescope.previewers'.vim_buffer_vimgrep.new,
        qflist_previewer = require'telescope.previewers'.vim_buffer_qflist.new,
      },
      pickers = {
        find_files = { theme = 'ivy', no_ignore = false },
        live_grep = { theme = 'ivy' },
        grep_string = { theme = 'ivy' },
        current_buffer_fuzzy_find = { theme = 'ivy' },
        buffers = { theme = 'ivy' },
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
}

plugins['lewis6991/gitsigns.nvim'] = {
  event = 'VimEnter',
  requires = {'nvim-lua/plenary.nvim'},
  config = function ()
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
        ['n ]c'] = { expr = true, "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'"},
        ['n [c'] = { expr = true, "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'"},

        -- ['n <leader>hs'] = '<cmd>lua require"gitsigns".stage_hunk()<CR>',
        -- ['n <leader>hu'] = '<cmd>lua requiregitsigns".undo_stage_hunk()<CR>',
        -- ['n <leader>hr'] = '<cmd>lua require"gitsigns".reset_hunk()<CR>',
        -- ['n <leader>hR'] = '<cmd>lua require"gitsigns".reset_buffer()<CR>',
        -- ['n <leader>hp'] = '<cmd>lua require"gitsigns".preview_hunk()<CR>',

        -- Text objects
        ['o ih'] = ':<C-U>lua require"gitsigns".select_hunk()<CR>',
        ['x ih'] = ':<C-U>lua require"gitsigns".select_hunk()<CR>'
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
}

plugins['kyazdani42/nvim-web-devicons'] = {
  event = 'VimEnter',
}

plugins['folke/tokyonight.nvim'] = {
  event = 'VimEnter',
  config = function ()
    vim.g.tokyonight_transparent = false
    vim.g.tokyonight_transparent_sidebar = false
    vim.g.tokyonight_style = "night"
    vim.g.tokyonight_italic_functions = true
    vim.g.tokyonight_italic_comments = true
    vim.g.tokyonight_dark_sidebar = true
    vim.g.tokyonight_dark_float = true
    vim.api.nvim_exec(
      [[
        colorscheme tokyonight
        hi EndOfBuffer ctermfg=11 guifg=#3b4261
        hi VertSplit ctermfg=11 guifg=#3b4261
      ]],
      false
    )
  end
}

plugins["akinsho/nvim-bufferline.lua"] = {
  event = 'VimEnter',
  config = function ()
    require('bufferline').setup{
      options = {
        show_buffer_close_icons = false,
        show_close_icon = false,
        separator_style = "thick",
        always_show_bufferline = false,
      },
    }
  end
}

plugins["hoob3rt/lualine.nvim"] = {
  event = 'VimEnter',
  config = function ()
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
}

-- plugins['kyazdani42/nvim-tree.lua'] = {
--   -- cmd = {"NvimTreeToggle", "NvimTreeOpen"},
--   event = 'VimEnter',
--   config = function ()
--     vim.g["nvim_tree_indent_markers"] = 1
--     vim.g.nvim_tree_icons = {
--       default =  '',
--       symlink =  '',
--       git = {
--         unstaged = "✚",
--         staged =  "✚",
--         unmerged =  "≠",
--         renamed =  "≫",
--         untracked = "★",
--       },
--     }
--     require('nvim-tree').setup {
--       disable_netrw       = true,
--       hijack_netrw        = true,
--       auto_close          = true,
--       update_cwd          = true,
--       update_focused_file = {
--         enable      = true,
--         update_cwd  = false,
--         ignore_list = {}
--       },
--       view = {
--         width = 30,
--         side = 'left',
--         auto_resize = true,
--       }
--     }
--     -- require("nvim-tree.events").on_nvim_tree_ready(function()
--     --   vim.cmd("NvimTreeRefresh")
--     -- end)
--   end
-- }

plugins['goolord/alpha-nvim'] = {
  config = function ()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

  -- Set heade
  -- dashboard.section.header.val = {
    --   "                                                     ",
    --   "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
    --   "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
    --   "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
    --   "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
    --   "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
    --   "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
    --   "                                                     ",
    -- }

    dashboard.section.header.val = {
      "   ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣿⣶⣿⣦⣼⣆          ",
      "    ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡠⢾⣿⣿⡿⠋⠉⠉⠻⣿⣿⡛⣦       ",
      "          ⠈⢿⣿⣟⠦ ⣾⣿⣿⣷    ⠻⠿⢿⣿⣧⣄     ",
      "           ⣸⣿⣿⢧ ⢻⠻⣿⣿⣷⣄⣀⠄⠢⣀⡀⠈⠙⠿⠄    ",
      "          ⢠⣿⣿⣿⠈    ⣻⣿⣿⣿⣿⣿⣿⣿⣛⣳⣤⣀⣀   ",
      "   ⢠⣧⣶⣥⡤⢄ ⣸⣿⣿⠘  ⢀⣴⣿⣿⡿⠛⣿⣿⣧⠈⢿⠿⠟⠛⠻⠿⠄  ",
      "  ⣰⣿⣿⠛⠻⣿⣿⡦⢹⣿⣷   ⢊⣿⣿⡏  ⢸⣿⣿⡇ ⢀⣠⣄⣾⠄   ",
      " ⣠⣿⠿⠛ ⢀⣿⣿⣷⠘⢿⣿⣦⡀ ⢸⢿⣿⣿⣄ ⣸⣿⣿⡇⣪⣿⡿⠿⣿⣷⡄  ",
      " ⠙⠃   ⣼⣿⡟  ⠈⠻⣿⣿⣦⣌⡇⠻⣿⣿⣷⣿⣿⣿ ⣿⣿⡇ ⠛⠻⢷⣄ ",
      "      ⢻⣿⣿⣄   ⠈⠻⣿⣿⣿⣷⣿⣿⣿⣿⣿⡟ ⠫⢿⣿⡆     ",
      "       ⠻⣿⣿⣿⣿⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⡟⢀⣀⣤⣾⡿⠃     ",
    }
    -- Set menu
    dashboard.section.buttons.val = {
      dashboard.button( "e", "> New file", ":ene<CR>"),
      dashboard.button( "SPC f f", "> Find file", ":Telescope find_files hidden=true<CR>"),
      dashboard.button( "SPC f s", "> Search word", ":Telescope live_grep<CR>"),
      dashboard.button( "SPC f n", "> Directory", ":NnnPicker<CR>"),
      dashboard.button( "SPC f o", "> Recent", ":Telescope oldfiles<CR>"),
      dashboard.button( "SPC f t", "> Tree", ":NvimTreeToggle<CR>"),
      dashboard.button( "SPC h f", "> Dotfiles", ":Dff<CR>"),
      dashboard.button( "SPC h s", "> Dotfiles Search", ":Dfs<CR>"),
      dashboard.button( "SPC w w", "> Wiki", ":VimwikiIndex<CR>"),
      dashboard.button( "q", "> Quit NVIM", ":qa<CR>"),
    }

    alpha.setup(dashboard.opts)
  end
}

return plugins
