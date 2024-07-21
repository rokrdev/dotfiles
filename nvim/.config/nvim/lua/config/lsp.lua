local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
  if client.server_capabilities.documentSymbolProvider then
    require('nvim-navic').attach(client, bufnr)
  end
end)

--- if you want to know more about lsp-zero and mason.nvim
--- read this: https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guide/integrate-with-mason-nvim.md
require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {
    "angularls",
    "ansiblels",
    "bashls",
    "diagnosticls",
    "dockerls",
    "elixirls",
    "graphql",
    "html",
    "jsonls",
    "kotlin_language_server",
    "pyright",
    "solargraph",
    "sqlls",
    "lua_ls",
    "terraformls",
    "tsserver",
    "vimls",
    "yamlls",
  },
  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup({})
    end,
    lua_ls = function()
      require('lspconfig').lua_ls.setup({
        ---
        -- in here you can add your own
        -- custom configuration
        settings = {
          Lua = {
            diagnostics = {
              globals = { 'vim', 'hs' }
            }
          }
        }
      })
  end,
  diagnosticls = function()
    require('lspconfig').diagnosticls.setup({
      filetypes = {
        "javascript",
        "javascript.jsx",
        'typescript',
        'typescriptreact',
        'css',
        'scss',
        'markdown',
        'pandoc',
        'telekasten',
      },
      init_options = {
        filetypes = {
          javascript = "eslint",
          ["javascript.jsx"] = "eslint",
          javascriptreact = "eslint",
          typescriptreact = "eslint",
          markdown = 'markdownlint',
          pandoc = 'markdownlint',
          telekasten = 'markdownlint'
        },
        linters = {
          eslint = {
            sourceName = "eslint",
            command = "./node_modules/.bin/eslint",
            rootPatterns = { ".git" },
            debounce = 100,
            args = {
              "--stdin",
              "--stdin-filename",
              "%filepath",
              "--format",
              "json",
            },
            parseJson = {
              errorsRoot = "[0].messages",
              line = "line",
              column = "column",
              endLine = "endLine",
              endColumn = "endColumn",
              message = "(eslint) ${message} [${ruleId}]",
              security = "severity",
            };
            securities = {
              [2] = "error",
              [1] = "warning"
            }
          },
          markdownlint = { -- yarn global add markdownlint-cli
            command = 'markdownlint',
            rootPatterns = { '.git' },
            isStderr = true,
            debounce = 100,
            args = { '--stdin' },
            offsetLine = 0,
            offsetColumn = 0,
            sourceName = 'markdownlint',
            securities = {
              undefined = 'hint'
            },
            formatLines = 1,
            formatPattern = {
              '^.*:(\\d+)\\s+(.*)$',
              {
                line = 1,
                column = -1,
                message = 2,
              }
            }
          }
        }
      }
    })
  end,
  elixirls = function ()
    require('lspconfig').diagnosticls.setup({
      settings = {
        dialyzerEnabled = true,
        dialyzerWarnOpts = {
          enum = {
            "error_handling",
            "no_behaviours",
            "no_contracts",
            "no_fail_call",
            "no_fun_app",
            "no_improper_lists",
            "no_match",
            "no_missing_calls",
            "no_opaque",
            "no_return",
            "no_undefined_callbacks",
            "no_unused",
            "underspecs",
            "unknown",
            "unmatched_returns",
            "overspecs",
            "specdiffs"
          },
          type = "string"
        }
      }
    })
  end
  },
})

