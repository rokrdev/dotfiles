local set_option = vim.api.nvim_buf_set_option
local set_keymap = vim.keymap.set

local on_attach = function(client, bufnr)

  set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  local bufopts = { noremap = true, silent = true, buffer = bufnr }

  -- Mappings.
  set_keymap('n', 'gD', vim.lsp.buf.declaration, bufopts)
  set_keymap('n', 'gd', vim.lsp.buf.definition, bufopts)
  set_keymap('n', 'K', vim.lsp.buf.hover, bufopts)
  set_keymap('n', 'gi', vim.lsp.buf.implementation, bufopts)
  set_keymap('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  -- set_keymap('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', bufopts)
  -- set_keymap('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', bufopts)
  -- set_keymap('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', bufopts)
  set_keymap('n', '<leader>ld', vim.lsp.buf.type_definition, bufopts)
  set_keymap('n', '<leader>lc', vim.lsp.buf.rename, bufopts)
  set_keymap('n', 'gr', vim.lsp.buf.references, bufopts)
  set_keymap('n', '<leader>ll', vim.diagnostic.open_float, bufopts)
  set_keymap('n', '[d', vim.diagnostic.goto_prev, bufopts)
  set_keymap('n', ']d', vim.diagnostic.goto_next, bufopts)
  set_keymap('n', '<leader>lq', vim.diagnostic.setloclist, bufopts)
  set_keymap('n', '<leader>lf', function()
    vim.lsp.buf.format({ async = true })
  end, bufopts)

  local function setupSign()
    local signs = {
      ["Error"] = "",
      ["Warning"] = "",
      ["Hint"] = "",
      ["Information"] = ""
    }

    for k, v in pairs(signs) do
      vim.api.nvim_call_function("sign_define", {
        "LspDiagnosticsSign" .. k,
        { text = v, texthl = "LspDiagnosticsSign" .. k }
      })
    end
  end

  setupSign()
end

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
capabilities.textDocument.completion.completionItem.snippetSupport = true

local servers = {
  "angularls",
  "ansiblels",
  "bashls",
  "diagnosticls",
  "dockerls",
  "elixirls",
  "graphql",
  "html",
  -- "jdtls", disable java
  "jsonls",
  "kotlin_language_server",
  "pyright",
  "solargraph",
  "sqls",
  "sumneko_lua",
  "terraformls",
  "tsserver",
  "vimls",
  "yamlls",
}

require("mason-lspconfig").setup {
  automatic_installation = true,
}

local lspconfig = require("lspconfig")
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end
lspconfig.sumneko_lua.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim', 'hs' }
      }
    }
  }
}
lspconfig.elixirls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
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
}
lspconfig.diagnosticls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
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
}

