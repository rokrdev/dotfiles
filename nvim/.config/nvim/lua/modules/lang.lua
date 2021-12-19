local plugins = {}

plugins['nvim-treesitter/nvim-treesitter'] = {
  config = function ()
    -- vim.api.nvim_command('set foldmethod=expr')
    -- vim.api.nvim_command('set foldexpr=nvim_treesitter#foldexpr()')
    require('nvim-treesitter.configs').setup {
      ensure_installed = "maintained",
      sync_install = true,
      highlight = {
        enable = true
      },
      indent = {
        enable = false,
      },
      context_commentstring = {
        enable = true,
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "gnn",
          node_incremental = "grn",
          scope_incremental = "grc",
          node_decremental = "grm",
        },
      },
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

plugins['nvim-treesitter/playground'] = {
  cmd = 'TSPlaygroundToggle'
}

plugins['elixir-editors/vim-elixir'] = {
  opt = true,
  ft = {'elixir', 'eelixir'},
}

plugins['JoosepAlviste/nvim-ts-context-commentstring'] = {
  requires = {'nvim-treesitter', 'tpope/vim-commentary'},
}

plugins['nvim-treesitter/nvim-treesitter-textobjects'] = {
  requires = 'nvim-treesitter',
}

plugins['styled-components/vim-styled-components'] = {
  branch = 'main',
  opt = true,
  ft = {'javascript', 'typescript', 'javascriptreact'},
}

plugins['jxnblk/vim-mdx-js'] = {
  opt = true,
  ft = {'mdx'}
}

plugins['iamcco/markdown-preview.nvim'] = {
  opt = true,
  ft = {'markdown'},
  run = 'cd app && yarn install',
  cmd = 'MarkdownPreview'
}

return plugins
