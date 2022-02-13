local plugins = {}

plugins['nvim-treesitter/nvim-treesitter'] = {
  config = function ()
    require('nvim-treesitter.configs').setup {
      ensure_installed = "maintained",
      sync_install = true,
      ignore_install = { "norg" },
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
    }
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

plugins['nvim-treesitter/nvim-treesitter-textobjects'] = {
  requires = 'nvim-treesitter',
}

return plugins
