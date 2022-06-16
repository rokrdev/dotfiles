local plugins = {}

plugins["lewis6991/impatient.nvim"] = {
  config = function ()
    require'impatient'
  end
}

plugins["neovim/nvim-lspconfig"] = {
  event = "BufReadPost",
  requires = 'hrsh7th/cmp-nvim-lsp',
  config = function ()
    vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
      vim.lsp.diagnostic.on_publish_diagnostics, {
        -- delay update diagnostics
        update_in_insert = false,
      }
    )
  end
}

plugins["williamboman/nvim-lsp-installer"] = {
  event = "BufReadPost",
  requires = {'neovim/nvim-lspconfig'},
  config = function ()
    require'config.lsp'
  end
}

plugins["hrsh7th/cmp-buffer"] = {
  event = "BufReadPost",
  requires = 'hrsh7th/nvim-cmp',
}

plugins["hrsh7th/cmp-nvim-lsp"] = {
  event = "BufReadPost",
  requires = 'hrsh7th/nvim-cmp',
}

plugins["hrsh7th/cmp-vsnip"] = {
  event = "BufReadPost",
  requires = 'hrsh7th/nvim-cmp',
}

plugins["hrsh7th/cmp-nvim-lsp-signature-help"] = {
  event = "BufReadPost",
  requires = 'hrsh7th/nvim-cmp',
}

plugins["hrsh7th/vim-vsnip"] = {
  event = "BufReadPost",
  config = function ()
    vim.g.vsnip_snippet_dir = '~/.config/nvim/vsnip'
  end
}

plugins["hrsh7th/cmp-cmdline"] = {
  event = "BufReadPost",
  requires = 'hrsh7th/nvim-cmp',
}

plugins["hrsh7th/cmp-path"] = {
  event = "BufReadPost",
  requires = 'hrsh7th/nvim-cmp',
}

plugins["hrsh7th/nvim-cmp"] = {
  event = "BufReadPost",
  config = function ()
    require'config.cmp'
  end
}

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
  event = 'BufWinEnter',
  config = function ()
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
    vim.g.indent_blankline_use_treesitter = true
    require('indent_blankline').setup {
      show_current_context = true,
      -- show_current_context_start = true,
      buftype_exclude = {'terminal'},
      filetype_exclude = {'alpha', 'help', 'packer', 'NvimTree'},
    }
  end
}

plugins["tpope/vim-repeat"] = {
  event = 'VimEnter'
}

plugins['ggandor/leap.nvim'] = {
  event = 'VimEnter',
  config = function ()
    require'leap'.setup {
      case_insensitive = true,
      special_keys = {
        repeat_search = '<enter>',
        next_match    = '<enter>',
        prev_match    = '<tab>',
        next_group    = '<space>',
        prev_group    = '<tab>',
        eol           = '<space>',
      },
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
    require'config.neogit'
  end
}

plugins['akinsho/git-conflict.nvim'] = {
  config = function()
    require('git-conflict').setup()
  end
}

plugins['nvim-treesitter/nvim-treesitter'] = {
  after = "tokyonight.nvim",
  config = function ()
    require'config.treesitter'
  end
}

plugins['numToStr/Comment.nvim'] = {
  event = 'VimEnter',
  config = function()
    require("Comment").setup({
      ignore = '^$',
      pre_hook = function(ctx)
        -- Only calculate commentstring for tsx filetypes
        if vim.bo.filetype == 'typescriptreact' then
          local U = require('Comment.utils')

          -- Detemine whether to use linewise or blockwise commentstring
          local type = ctx.ctype == U.ctype.line and '__default' or '__multiline'

          -- Determine the location where to calculate commentstring from
          local location = nil
          if ctx.ctype == U.ctype.block then
            location = require('ts_context_commentstring.utils').get_cursor_location()
          elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
            location = require('ts_context_commentstring.utils').get_visual_start_location()
          end

          return require('ts_context_commentstring.internal').calculate_commentstring({
            key = type,
            location = location,
          })
        end
      end,
    })
    local ft = require('Comment.ft')
    ft.set('fish', '# %s')
  end
}

plugins['JoosepAlviste/nvim-ts-context-commentstring'] = {
  event = 'VimEnter',
  requires = {'nvim-treesitter', 'Comment.nvim'},
}

plugins['nvim-treesitter/nvim-treesitter-textobjects'] = {
  event = 'VimEnter',
  requires = 'nvim-treesitter',
  config = function()
    require'nvim-treesitter.configs'.setup {
      textobjects = {
        select = {
          enable = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
          },
        },
      },
    }
  end
}

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
  -- event = 'VimEnter',
  requires = {
    {'nvim-lua/popup.nvim'},
    {'nvim-lua/plenary.nvim'},
    {'nvim-telescope/telescope-fzf-native.nvim', run = 'make'},
  },
  config = function ()
    require'config.telescope'
  end
}

plugins['lewis6991/gitsigns.nvim'] = {
  event = 'VimEnter',
  requires = {'nvim-lua/plenary.nvim'},
  config = function ()
    require'config.gitsigns'
  end
}

plugins['kyazdani42/nvim-web-devicons'] = {
  -- event = 'VimEnter',
}

plugins['folke/tokyonight.nvim'] = {
  event = "BufReadPost",
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
        hi SpecialKey    guifg=#61AFEF
        hi SpecialKeyWin guifg=#3B4048
        set winhighlight=SpecialKey:SpecialKeyWin
      ]],
      false
    )
  end
}

-- plugins["akinsho/nvim-bufferline.lua"] = {
--   -- event = 'VimEnter',
--   config = function ()
--     require('bufferline').setup{
--       options = {
--         show_buffer_close_icons = false,
--         show_close_icon = false,
--         separator_style = "thick",
--         always_show_bufferline = false,
--       },
--     }
--   end
-- }

plugins["beauwilliams/focus.nvim"] = {
  event = 'VimEnter',
  config = function ()
    require("focus").setup({
      cursorline = false,
      cursorcolumn = false,
      signcolumn = false,
      excluded_filetypes = {"nnn"}
    })
  end
}

plugins["petertriho/nvim-scrollbar"] = {
  opt = true,
  after = {
    "nvim-hlslens",
    "tokyonight.nvim"
  },
  config = function ()
    require("scrollbar").setup({
      show = true,
      set_highlights = true,
      handlers = {
        diagnostic = true,
        search = true, -- Requires hlslens to be loaded, will run require("scrollbar.handlers.search").setup() for you
      },
    })
    require("scrollbar.handlers.search").setup()
  end
}

plugins["hoob3rt/lualine.nvim"] = {
  after = "tokyonight.nvim",
  config = function ()
    require'config.statusline'
  end
}

plugins['kyazdani42/nvim-tree.lua'] = {
  event = 'VimEnter',
  config = function ()
    require'config.nvim_tree'
  end
}

plugins['goolord/alpha-nvim'] = {
  config = function ()
    require'config.alpha'
  end
}

plugins["renerocksai/telekasten.nvim"] = {
  event = 'VimEnter',
  config = function ()
    require'config.telekasten'
  end
}

plugins["mattn/calendar-vim"] = {
  event = 'VimEnter',
}

plugins["ellisonleao/glow.nvim"] = {
  cmd = 'Glow',
  setup = function ()
    vim.g.glow_border = "rounded"
    vim.g.glow_use_pager = true
  end
}

return plugins
