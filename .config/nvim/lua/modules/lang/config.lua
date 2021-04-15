local config = {}

function config.treesitter()
  require('nvim-treesitter.configs').setup {
    ensure_installed = {
      'bash', 'css', 'dart', 'go', 'graphql', 'html', 'java', 'javascript', 'json', 'kotlin',
      'lua', 'php', 'python', 'ruby', 'rust', 'svelte', 'tsx', 'typescript', 'vue', 'yaml'
    },
    highlight = {
      enable = true
    },
    indent = {
      enable = false,
    },
    disable = { "elixir" },
    context_commentstring = {
      enable = true,
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<M-h>",
        node_incremental = "<M-j>",
        scope_incremental = "<M-l>",
        node_decremental = "<M-k>",
      },
    },
  }
end

return config
