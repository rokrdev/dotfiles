require("lazy").setup({
  {
    "neovim/nvim-lspconfig",
    event = 'VeryLazy',
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
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    keys = {
      -- 👇 in this section, choose your own keymappings!
      {
        "<leader>fn",
        function()
          require("yazi").yazi()
        end,
        desc = "Open the file manager",
      },
      {
        -- Open in the current working directory
        "<leader>cw",
        function()
          require("yazi").yazi(nil, vim.fn.getcwd())
        end,
        desc = "Open the file manager in nvim's working directory" ,
      },
    },
    opts = {
      -- if you want to open yazi instead of netrw, see below for more info
      open_for_directories = false,
    },
  },

  {
    "smoka7/multicursors.nvim",
    event = "VeryLazy",
    dependencies = {
      'smoka7/hydra.nvim',
    },
    opts = {},
    cmd = { 'MCstart', 'MCvisual', 'MCclear', 'MCpattern', 'MCvisualPattern', 'MCunderCursor' },
    keys = {
      {
        mode = { 'v', 'n' },
        '<Leader>m',
        '<cmd>MCstart<cr>',
        desc = 'Create a selection for selected text or word under the cursor',
      },
    },
  },

  {
    "SmiteshP/nvim-navic",
    event = "VeryLazy",
    dependencies = 'neovim/nvim-lspconfig',
    config = function ()
      require'config.navic'
    end
  },

  {
    "williamboman/mason.nvim",
    event = "VeryLazy",
    config = function ()
      require("mason").setup()
    end
  },

  {
    "williamboman/mason-lspconfig.nvim",
    event = "VeryLazy",
    dependencies = {'neovim/nvim-lspconfig', 'williamboman/mason.nvim'},
    config = function ()
      require'config.lsp'
    end
  },

  {
    'VonHeikemen/lsp-zero.nvim', branch = 'v3.x',
  },

  {
    "hrsh7th/cmp-nvim-lsp",
    event = "VeryLazy",
    dependencies = 'hrsh7th/nvim-cmp',
  },

  {
    "hrsh7th/cmp-buffer",
    event = "VeryLazy",
    dependencies = 'hrsh7th/nvim-cmp',
  },

  {
    "hrsh7th/cmp-nvim-lsp",
    event = "VeryLazy",
    dependencies = 'hrsh7th/nvim-cmp',
  },

  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    event = "VeryLazy",
    build = "make install_jsregexp",
    config = function ()
      local ls = require'luasnip'
      ls.config.set_config {
        enable_autosnippets = true,
      }

      require("luasnip.loaders.from_lua").load({paths = "~/.config/snippets/luasnippets"})
      ls.filetype_extend("javascript", { "javascriptreact" })
      ls.filetype_extend("javascript", { "html" })
    end
  },

  {
    "saadparwaiz1/cmp_luasnip",
    event = "VeryLazy",
    dependencies = 'hrsh7th/nvim-cmp',
  },

  {
    "hrsh7th/cmp-nvim-lsp-signature-help",
    event = "VeryLazy",
    dependencies = 'hrsh7th/nvim-cmp',
  },

  {
    "hrsh7th/vim-vsnip",
    event = "VeryLazy",
    config = function ()
      vim.g.vsnip_snippet_dir = '~/.config/nvim/vsnip'
    end
  },

  {
    "hrsh7th/cmp-cmdline",
    event = "VeryLazy",
    dependencies = 'hrsh7th/nvim-cmp',
  },

  {
    "hrsh7th/cmp-path",
    event = "VeryLazy",
    dependencies = 'hrsh7th/nvim-cmp',
  },

  {
    "hrsh7th/nvim-cmp",
    event = "VeryLazy",
    config = function ()
      require'config.cmp'
    end
  },

  {
    "norcalli/nvim-colorizer.lua",
    event = "VeryLazy",
    config = function ()
      require('colorizer').setup()
    end
  },

  {
    "zenobht/cursorword.nvim",
    event = "VeryLazy",
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
    event = "VeryLazy",
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
    event = "VeryLazy",
    config = function ()
      local npairs = require('nvim-autopairs')
      npairs.setup()
      -- local Rule = require('nvim-autopairs.rule')
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
    main = "ibl",
    opts = {
      exclude = {
        buftypes = {'terminal'},
        filetypes = {'alpha', 'help', 'packer', 'NvimTree'},
      },
      scope = {
        enabled = false,
      },
    },
    event = "BufReadPost",
  },

  {
    "tpope/vim-repeat",
    event = "VeryLazy",
  },

  {
    'phaazon/hop.nvim',
    branch = 'v2',
    event = "VeryLazy",
    config = function()
      require'hop'.setup { keys = 'etovxqpdygfblzhckisuran' }
    end
  },

  {
    'kevinhwang91/nvim-hlslens',
    event = "VeryLazy",
    config = function ()
      require('hlslens').setup()
    end
  },

  {
    'kylechui/nvim-surround',
    event = "VeryLazy",
    config = function ()
      require'nvim-surround'.setup {}
    end
  },

  {
    'andymass/vim-matchup',
    event = "VeryLazy",
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
    event = "VeryLazy",
    config = function()
      require('git-conflict').setup()
    end
  },

  {
    'nvim-treesitter/nvim-treesitter',
    config = function ()
      require'config.treesitter'
    end
  },

  {
    'numToStr/Comment.nvim',
    event = "VeryLazy",
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
    event = "VeryLazy",
    dependencies = {'nvim-treesitter', 'Comment.nvim'},
  },

  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    event = "VeryLazy",
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
    "ibhagwan/fzf-lua",
    event = 'VeryLazy',
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- calling `setup` is optional for customization
      require('fzf-lua').setup({
        'fzf-native',
        files = {
          actions = {
            ["ctrl-g"] = false
          }
        },
        grep = {
          rg_opts = "--sort-files --hidden --column --line-number --no-heading " ..
          "--color=always --smart-case -g '!{.git,node_modules}/*'",
        },
        fzf_opts = {['--layout'] = 'default'}
      })
    end
  },

  {
    'lewis6991/gitsigns.nvim',
    event = 'VeryLazy',
    dependencies = {'nvim-lua/plenary.nvim'},
    config = function ()
      require'config.gitsigns'
    end
  },

  {
    'kyazdani42/nvim-web-devicons',
    event = 'VeryLazy',
  },

  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    config = function()
      require'tokyonight'.setup({
        style = "night"
      })
      vim.api.nvim_exec(
      [[
      colorscheme tokyonight
      hi link Trailspace CurSearch
      ]],
      false
      )
    end
  },

  {
    "hoob3rt/lualine.nvim",
    lazy = false,
    config = function ()
      require'config.status_line'
    end
  },

  -- {
  --   "akinsho/bufferline.nvim",
  --   version = "*",
  --   dependencies = 'nvim-tree/nvim-web-devicons',
  --   event = 'VeryLazy',
  --   config = function ()
  --     require('bufferline').setup{
  --       options = {
  --         exclude_ft = {'alpha'},
  --         show_buffer_close_icons = false,
  --         show_close_icon = false,
  --         separator_style = "thick",
  --         always_show_bufferline = false,
  --       },
  --     }
  --   end
  -- },

  {
    'kyazdani42/nvim-tree.lua',
    event = 'VeryLazy',
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
      require("which-key").setup {
        preset = "modern"
      }
    end
  },

  {
    "Pocco81/auto-save.nvim",
    event = 'VeryLazy',
  }
},
{
  lockfile = vim.fn.stdpath("data") .. "/lazy/lazy-lock.json",
  defaults = { lazy = true }
}
)
