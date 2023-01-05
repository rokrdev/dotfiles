require("lazy").setup({

  {
    "neovim/nvim-lspconfig",
    event = "BufReadPost",
    dependencies = 'hrsh7th/cmp-nvim-lsp',
    config = function ()
      vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
      vim.lsp.diagnostic.on_publish_diagnostics, {
        -- delay update diagnostics
        update_in_insert = false,
      }
      )
    end
  },

  {
    "SmiteshP/nvim-navic",
    event = "BufReadPost",
    dependencies = 'neovim/nvim-lspconfig',
    config = function ()
      require'config.navic'
    end
  },

  {
    "williamboman/mason.nvim",
    event = "BufReadPost",
    config = function ()
      require("mason").setup()
    end
  },

  {
    "williamboman/mason-lspconfig.nvim",
    event = "BufReadPost",
    dependencies = {'neovim/nvim-lspconfig', 'williamboman/mason.nvim'},
    config = function ()
      require'config.lsp'
    end
  },

  {
    "hrsh7th/cmp-buffer",
    event = "VimEnter",
    dependencies = 'hrsh7th/nvim-cmp',
  },

  {
    "hrsh7th/cmp-nvim-lsp",
    event = "BufRead",
    dependencies = 'hrsh7th/nvim-cmp',
  },

  {
    "hrsh7th/cmp-vsnip",
    event = "BufRead",
    dependencies = 'hrsh7th/nvim-cmp',
  },

  {
    "hrsh7th/cmp-nvim-lsp-signature-help",
    event = "BufRead",
    dependencies = 'hrsh7th/nvim-cmp',
  },

  {
    "hrsh7th/vim-vsnip",
    event = "BufRead",
    config = function ()
      vim.g.vsnip_snippet_dir = '~/.config/nvim/vsnip'
    end
  },

  {
    "hrsh7th/cmp-cmdline",
    event = "VimEnter",
    dependencies = 'hrsh7th/nvim-cmp',
  },

  {
    "hrsh7th/cmp-path",
    event = "VimEnter",
    dependencies = 'hrsh7th/nvim-cmp',
  },

  {
    "hrsh7th/nvim-cmp",
    event = "VimEnter",
    config = function ()
      require'config.cmp'
    end
  },

  {
    "norcalli/nvim-colorizer.lua",
    event = 'BufReadPost',
    config = function ()
      require('colorizer').setup()
    end
  },

  {
    "zenobht/cursorword.nvim",
    event = 'BufReadPost',
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
  },

  {
    "zenobht/trailspace.nvim",
    event = 'BufReadPost',
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
  },

  {
    'windwp/nvim-autopairs',
    event = 'BufReadPost',
    config = function ()
      local npairs = require('nvim-autopairs')
      npairs.setup()
      local Rule = require('nvim-autopairs.rule')

      -- npairs.add_rules({
        --     Rule("```", "```", { 'telekasten' }),
        --     Rule("```.*$", "```", { 'telekasten' })
        -- })

        vim.g.completion_confirm_key = ""
      end
  },

  {
    'gpanders/editorconfig.nvim',
    ft = { 'go','vim','rust', 'kotlin', 'java' }
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    dependencies = 'catppuccin',
    event = "BufReadPost",
    config = function ()
      vim.g.indent_blankline_use_treesitter = true
      -- vim.g.indent_blankline_space_char_blankline = "⋅"
      require('indent_blankline').setup {
        show_current_context = false,
        -- show_current_context_start = true,
        buftype_exclude = {'terminal'},
        filetype_exclude = {'alpha', 'help', 'packer', 'NvimTree'},
      }
    end
  },

  {
    "tpope/vim-repeat",
    event = 'BufReadPost'
  },

  {
    'phaazon/hop.nvim',
    branch = 'v2',
    event = 'BufReadPost',
    config = function()
      require'hop'.setup { keys = 'etovxqpdygfblzhckisuran' }
    end
  },

  {
    'wincent/scalpel',
    event = 'BufReadPost',
    setup = function ()
      vim.g.ScalpelMap=0
    end
  },

  {
    'kevinhwang91/nvim-hlslens',
    event = 'BufReadPost',
    config = function ()
      require('hlslens').setup()
    end
  },

  {
    'kylechui/nvim-surround',
    event = 'BufReadPost',
    config = function ()
      require'nvim-surround'.setup {}
    end
  },

  {
    'wellle/targets.vim',
    event = 'BufReadPost',
  },

  {
    'andymass/vim-matchup',
    event = 'BufReadPost',
    setup = function ()
      vim.g.matchup_matchparen_offscreen = {}
    end
  },

  {
    'TimUntersberger/neogit',
    cmd = 'Neogit',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'sindrets/diffview.nvim',
    },
    config = function ()
      require'config.neogit'
    end
  },

  {
    'akinsho/git-conflict.nvim',
    event = 'VimEnter',
    config = function()
      require('git-conflict').setup()
    end
  },

  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = "catppuccin",
    config = function ()
      require'config.treesitter'
    end
  },

  {
    'numToStr/Comment.nvim',
    event = 'BufReadPost',
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
  },

  {
    'JoosepAlviste/nvim-ts-context-commentstring',
    event = 'BufReadPost',
    dependencies = {'nvim-treesitter', 'Comment.nvim'},
  },

  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    event = 'BufReadPost',
    dependencies = 'nvim-treesitter',
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
  },

  {
    "luukvbaal/nnn.nvim",
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
  },

  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/popup.nvim',
      'nvim-lua/plenary.nvim',
    },
    config = function ()
      require'config.telescope'
    end
  },

  {
    'nvim-telescope/telescope-fzf-native.nvim', 
    build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
    config = function ()
      require('telescope').load_extension('fzf')
    end
  },

  {
    'lewis6991/gitsigns.nvim',
    event = 'BufReadPost',
    dependencies = {'nvim-lua/plenary.nvim'},
    config = function ()
      require'config.gitsigns'
    end
  },

  {
    'kyazdani42/nvim-web-devicons',
    event = 'VimEnter',
  },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    config = function ()
      require("catppuccin").setup {
        transparent_background = false,
        dim_inactive = {
          enabled = true,
          shade = "dark",
          percentage = 0.15,
        },
        compile = {
          enabled = true,
          path = vim.fn.stdpath "cache" .. "/catppuccin",
        },
        integrations = {
          which_key = true,
          neogit = true,
          gitsigns = true,
          hop = true,
          native_lsp = {
            enabled = true,
          },
          cmp = true,
          nvimtree = true,
          telescope = true,
          treesitter = true,
          indent_blankline = {
            enabled = true,
            colored_indent_levels = false,
          },
          navic = {
            enabled = true,
          }
        }
      }
      vim.g.catppuccin_flavour = "mocha"
      vim.api.nvim_exec(
      [[
      colorscheme catppuccin
      hi link Trailspace CurSearch
      ]],
      false
      )
    end
  },

  {
    "beauwilliams/focus.nvim",
    event = 'BufReadPost',
    config = function ()
      require("focus").setup({
        cursorline = false,
        cursorcolumn = false,
        signcolumn = false,
        excluded_filetypes = {"nnn"}
      })
    end
  },

  {
    "petertriho/nvim-scrollbar",
    event = 'BufReadPost',
    dependencies = {
      "nvim-hlslens",
      "catppuccin"
    },
    config = function ()
      require("scrollbar").setup({
        show = true,
        set_highlights = true,
        handlers = {
          cursor = true,
          diagnostic = true,
          gitsigns = false, -- dependencies gitsigns
          handle = true,
          search = false, -- dependencies hlslens,
        }
      })
      require("scrollbar.handlers.search").setup()
    end
  },

  {
    "hoob3rt/lualine.nvim",
    lazy = false,
    dependencies = "catppuccin",
    config = function ()
      require'config.status_line'
    end
  },

  {
    "akinsho/nvim-bufferline.lua",
    dependencies = "lualine.nvim",
    event = "VimEnter",
    config = function ()
      require('bufferline').setup{
        options = {
          show_buffer_close_icons = false,
          show_close_icon = false,
          separator_style = "thick",
          always_show_bufferline = false,
        },
        highlights = require("catppuccin.groups.integrations.bufferline").get()
      }
    end
  },

  {
    'kyazdani42/nvim-tree.lua',
    event = 'BufReadPost',
    cmd = 'NvimTreeToggle',
    config = function ()
      require'config.nvim_tree'
    end
  },

  {
    'goolord/alpha-nvim',
    lazy = false,
    config = function ()
      require'config.alpha'
    end
  },

  {
    "mattn/calendar-vim",
    event = 'BufReadPost',
  },

  {
    "iamcco/markdown-preview.nvim",
    run = "cd app && npm install",
    setup = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown", "telekasten" },
  },


  {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup {}
    end
  }
},
{
  lockfile = vim.fn.stdpath("data") .. "/lazy/lazy-lock.json",
  defaults = { lazy = true }
}
)
