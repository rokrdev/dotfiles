local plugin = require('core.pack').register_plugin

plugin {
  "lewis6991/impatient.nvim",
  config = function ()
    require'impatient'
  end
}

plugin {
  "neovim/nvim-lspconfig",
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

plugin {
  "williamboman/mason.nvim",
  event = "BufReadPost",
  config = function ()
    require("mason").setup()
  end
}

plugin {
  "williamboman/mason-lspconfig.nvim",
  event = "BufReadPost",
  requires = {'neovim/nvim-lspconfig', 'williamboman/mason.nvim'},
  config = function ()
    require'config.lsp'
  end
}

plugin {
  "hrsh7th/cmp-buffer",
  event = "VimEnter",
  requires = 'hrsh7th/nvim-cmp',
}

plugin {
  "hrsh7th/cmp-nvim-lsp",
  event = "BufRead",
  requires = 'hrsh7th/nvim-cmp',
}

plugin {
  "hrsh7th/cmp-vsnip",
  event = "BufRead",
  requires = 'hrsh7th/nvim-cmp',
}

plugin {
  "hrsh7th/cmp-nvim-lsp-signature-help",
  event = "BufRead",
  requires = 'hrsh7th/nvim-cmp',
}

plugin {
  "hrsh7th/vim-vsnip",
  event = "BufRead",
  config = function ()
    vim.g.vsnip_snippet_dir = '~/.config/nvim/vsnip'
  end
}

plugin {
  "hrsh7th/cmp-cmdline",
  event = "VimEnter",
  requires = 'hrsh7th/nvim-cmp',
}

plugin {
  "hrsh7th/cmp-path",
  event = "VimEnter",
  requires = 'hrsh7th/nvim-cmp',
}

plugin {
  "hrsh7th/nvim-cmp",
  event = "VimEnter",
  config = function ()
    require'config.cmp'
  end
}

plugin {
  "norcalli/nvim-colorizer.lua",
  event = 'BufReadPost',
  config = function ()
    require('colorizer').setup()
  end
}

plugin {
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
}

plugin {
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
}

plugin {
  'windwp/nvim-autopairs',
  event = 'BufWinEnter',
  config = function ()
    local npairs = require('nvim-autopairs')
    npairs.setup()
    local Rule = require('nvim-autopairs.rule')

    npairs.add_rules({
        Rule("```", "```", { 'telekasten' }),
        Rule("```.*$", "```", { 'telekasten' })
    })

    vim.g.completion_confirm_key = ""
  end
}

plugin {
  'gpanders/editorconfig.nvim',
  ft = { 'go','vim','rust', 'kotlin', 'java' }
}

plugin {
  "lukas-reineke/indent-blankline.nvim",
  after = 'catppuccin',
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
}

plugin {
  "tpope/vim-repeat",
  event = 'BufReadPost'
}


plugin {
  'phaazon/hop.nvim',
  branch = 'v2',
  config = function()
    require'hop'.setup { keys = 'etovxqpdygfblzhckisuran' }
  end
}

plugin {
  'wincent/scalpel',
  event = 'BufReadPost',
  setup = function ()
    vim.g.ScalpelMap=0
  end
}

plugin {
  'kevinhwang91/nvim-hlslens',
  event = 'BufReadPost',
}

plugin {
  'ur4ltz/surround.nvim',
  event = 'BufReadPost',
  config = function ()
    require'surround'.setup { mappings_style = "surround"}
  end
}

plugin {
  'wellle/targets.vim',
  event = 'BufReadPost',
}

plugin {
  'andymass/vim-matchup',
  event = 'BufReadPost',
  setup = function ()
    vim.g.matchup_matchparen_offscreen = {}
  end
}

plugin {
  'TimUntersberger/neogit',
  cmd = 'Neogit',
  requires = {
    {'nvim-lua/plenary.nvim'},
    {'sindrets/diffview.nvim', opt = true},
  },
  config = function ()
    require'config.neogit'
  end
}

plugin {
  'akinsho/git-conflict.nvim',
  config = function()
    require('git-conflict').setup()
  end
}

plugin {
  'nvim-treesitter/nvim-treesitter',
  after = "catppuccin",
  config = function ()
    require'config.treesitter'
  end
}

plugin {
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
}

plugin {
  'JoosepAlviste/nvim-ts-context-commentstring',
  event = 'BufReadPost',
  requires = {'nvim-treesitter', 'Comment.nvim'},
}

plugin {
  'nvim-treesitter/nvim-treesitter-textobjects',
  event = 'BufReadPost',
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

plugin {
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
}

plugin {
  'nvim-telescope/telescope.nvim',
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

plugin {
  'lewis6991/gitsigns.nvim',
  event = 'BufReadPost',
  requires = {'nvim-lua/plenary.nvim'},
  config = function ()
    require'config.gitsigns'
  end
}

plugin {
  'kyazdani42/nvim-web-devicons',
  -- event = 'VimEnter',
}

plugin {
  "catppuccin/nvim",
  as = "catppuccin",
  config = function ()
    local colors = require("catppuccin.palettes").get_palette()
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
    }
    vim.g.catppuccin_flavour = "mocha"
    vim.api.nvim_exec(
      [[
        colorscheme catppuccin
        hi link Trailspace TSDanger
      ]],
      false
    )
  end
}

plugin {
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
}

plugin {
  "petertriho/nvim-scrollbar",
  opt = true,
  after = {
    "nvim-hlslens",
    "catppuccin"
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

plugin {
  "hoob3rt/lualine.nvim",
  after = "catppuccin",
  config = function ()
    require'config.status_line'
  end
}

plugin {
  "akinsho/nvim-bufferline.lua",
  tag = "v2.*",
  after = "lualine.nvim",
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

plugin {
  'kyazdani42/nvim-tree.lua',
  event = 'BufReadPost',
  config = function ()
    require'config.nvim_tree'
  end
}

plugin {
  'goolord/alpha-nvim',
  config = function ()
    require'config.alpha'
  end
}

plugin {
  "renerocksai/telekasten.nvim",
  event = 'BufReadPost',
  config = function ()
    require'config.telekasten'
  end
}

plugin {
  "mattn/calendar-vim",
  event = 'BufReadPost',
}

plugin {
  "ellisonleao/glow.nvim",
  cmd = 'Glow',
  config = function ()
    require('glow').setup({
      style = "dark",
      width = 120,
      pager = true,
    })
  end
}

-- plugin {
  -- "anuvyklack/hydra.nvim",
--   event = 'VimEnter',
--   config = function ()
--     require'config.hydra'
--   end
-- }

plugin {
  "folke/which-key.nvim",
  config = function()
    require("which-key").setup {}
  end
}

plugin {
  "karb94/neoscroll.nvim",
  config = function()
    require'neoscroll'.setup()
  end
}

