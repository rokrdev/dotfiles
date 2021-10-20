local config = {}

function config.lspconfig()
  local nvim_lsp = require('lspconfig')
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
      -- delay update diagnostics
      update_in_insert = false,
    }
  )

  local on_attach = function(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    local opts = { noremap=true, silent=true }
    buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    buf_set_keymap('n', '<Leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    buf_set_keymap('n', '<Leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    buf_set_keymap('n', '<Leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
    buf_set_keymap('n', '<Leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    buf_set_keymap('n', '<Leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    buf_set_keymap('n', '<Leader>cd', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
    buf_set_keymap('n', '<Leader>ck', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
    buf_set_keymap('n', '<Leader>cj', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
    buf_set_keymap('n', '<Leader>cl', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)

    -- Set some keybinds conditional on server capabilities
    if client.resolved_capabilities.document_formatting then
      buf_set_keymap("n", "<space>cf", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
    elseif client.resolved_capabilities.document_range_formatting then
      buf_set_keymap("n", "<space>cf", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
    end


    local function setupSign()
      local signs = {
        ["Error"] = "",
        ["Warning"] = "",
        ["Hint"] = "",
        ["Information"] = ""
      }

      for k, v in pairs(signs) do
        vim.api.nvim_call_function("sign_define", {
          "LspDiagnosticsSign"..k,
          { text = v, texthl = "LspDiagnosticsSign" .. k }
        })
      end
    end

    setupSign()
  end

  -- Use a loop to conveniently both setup defined servers
  -- and map buffer local keybindings when the language server attaches
  local servers = { "tsserver", "kotlin_language_server" }
  for _, lsp in ipairs(servers) do
    nvim_lsp[lsp].setup {
      on_attach = on_attach,
      capabilities = capabilities,
    }
  end

  local home = os.getenv("HOME")

  require("lspconfig").java_language_server.setup{
    cmd = { home .. "/.local/bin/java-language-server/dist/lang_server_mac.sh" },
  }

  require("lspconfig").elixirls.setup {
    cmd = { home .. "/.local/bin/elixir-ls/language_server.sh" },
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

  require("lspconfig").diagnosticls.setup {
    filetypes = {
      "javascript",
      "javascript.jsx",
      'typescript',
      'typescriptreact',
      'css',
      'scss',
      'markdown',
      'pandoc',
    },
    init_options = {
      filetypes = {
        javascript = "eslint",
        ["javascript.jsx"] = "eslint",
        javascriptreact = "eslint",
        typescriptreact = "eslint",
        markdown = 'markdownlint',
        pandoc = 'markdownlint'
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
        markdownlint = {
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
end

function config.completion()
  local remap = vim.api.nvim_set_keymap

  require'compe'.setup {
    enabled = true;
    autocomplete = true;
    debug = true;
    min_length = 1;
    preselect = 'disable';
    throttle_time = 80;
    source_timeout = 200;
    incomplete_delay = 400;
    max_abbr_width = 100;
    max_kind_width = 100;
    max_menu_width = 100;
    documentation = true;

    source = {
      path = true;
      buffer = true;
      calc = true;
      vsnip = true;
      nvim_lsp = true;
      nvim_lua = true;
    };
  }
end

function config.vsnip()
  vim.g.vsnip_snippet_dir = '~/.config/nvim/vsnip'
end

function config.autopairs()
  if packer_plugins['nvim-autopairs'] and not packer_plugins['nvim-autopairs'].loaded then
    vim.cmd [[packadd nvim-autopairs]]
  end
  require('nvim-autopairs').setup()

  local remap = vim.api.nvim_set_keymap

  vim.g.completion_confirm_key = ""
end

function config.scalpel()
  vim.g.ScalpelMap=0
end

function config.matchup()
  vim.g.matchup_matchparen_offscreen = {}
end

function config.telescope()
  if not packer_plugins['plenary.nvim'].loaded then
    vim.cmd [[packadd plenary.nvim]]
    vim.cmd [[packadd popup.nvim]]
    vim.cmd [[packadd telescope-fzf-writer.nvim]]
  end

  local actions = require('telescope.actions')
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
        },
      },
      sorting_strategy = 'descending',
      file_previewer = require'telescope.previewers'.vim_buffer_cat.new,
      grep_previewer = require'telescope.previewers'.vim_buffer_vimgrep.new,
      qflist_previewer = require'telescope.previewers'.vim_buffer_qflist.new,
    },
    extensions = {
      extensions = {
        fzf_writer = {
          use_highlighter = true,
        }
      }
    }
  }
  -- require('telescope').load_extension('fzf')
  vim.cmd([[packadd cfilter]])
end

-- function config.easymotion()
--   vim.g.EasyMotion_smartcase = 1
-- end

function config.sneak()
  vim.g["sneak#use_ic_scs"] = 1
end

function config.snap()
  local snap = require'snap'
  local file = snap.config.file:with {
    reverse = true,
    suffix = ">>",
    consumer = "fzf",
    hidden = true,
  }

  local vimgrep = snap.config.vimgrep:with {
    reverse = true,
    suffix = ">>",
    limit = 50000,
    hidden = true,
    prompt = "Grep",
  }

  snap.maps {
    { "<Leader>ff", file { producer = "ripgrep.file", prompt = "Files" }},
    { "<Leader>fs", vimgrep {}},
    { "<Leader>fw", vimgrep { filter_with = "cword" }},
    { "<Leader>fw", vimgrep { filter_with = "selection" },  { modes = { "x" } }},
    { "<Leader>b", snap.config.file {producer = "vim.buffer", reverse = true}},
    { "<Leader>gc", snap.config.file {
      try = {
        function(request)
          local cwd = snap.sync(vim.fn.getcwd)
          return snap.get'producer.git.general'(request, {args = {"diff","--name-only","--diff-filter=U"}, cwd = cwd})
        end
      },
      prompt = 'Conflicts',
      reverse = true,
    }},
  }
  vim.cmd([[packadd cfilter]])
end

function config.multi()
  vim.g.multi_cursor_use_default_mapping = 0
  vim.g.multi_cursor_start_word_key      = '<M-n>'
  vim.g.multi_cursor_start_key           = 'g<M-n>'
  vim.g.multi_cursor_next_key            = '<M-n>'
  vim.g.multi_cursor_prev_key            = '<M-p>'
  vim.g.multi_cursor_skip_key            = '<M-x>'
  vim.g.multi_cursor_quit_key            = '<Esc>'
end

function config.treesitter()
  -- vim.api.nvim_command('set foldmethod=expr')
  -- vim.api.nvim_command('set foldexpr=nvim_treesitter#foldexpr()')
  require('nvim-treesitter.configs').setup {
    ensure_installed = "maintained",
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
    -- textobjects = {
    --   select = {
    --     enable = true,
    --     keymaps = {
    --       ["af"] = "@function.outer",
    --       ["if"] = "@function.inner",
    --       ["ac"] = "@class.outer",
    --       ["ic"] = "@class.inner",
    --     },
    --   },
    -- },
  }
end

function config.bufferline()
  require('bufferline').setup{
    options = {
      show_buffer_close_icons = false,
      show_close_icon = false,
      separator_style = "thick",
      always_show_bufferline = false,
    },
  }
end

function config.lualine()
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
        {'diagnostics', sources = {'nvim_lsp'}, sections = {'error', 'warn'}},
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

function config.colorizer()
  require('colorizer').setup()
end

function config.tree()
  vim.g["nvim_tree_indent_markers"] = 1
  vim.g.nvim_tree_icons = {
    default =  '',
    symlink =  '',
    git = {
      unstaged = "✚",
      staged =  "✚",
      unmerged =  "≠",
      renamed =  "≫",
      untracked = "★",
    },
  }
  require('nvim-tree').setup {
    disable_netrw       = true,
    hijack_netrw        = true,
    auto_close          = true,
    update_cwd          = true,
    update_focused_file = {
      enable      = true,
      update_cwd  = false,
      ignore_list = {}
    },
    view = {
      width = 30,
      side = 'left',
      auto_resize = true,
    }
  }
  -- require("nvim-tree.events").on_nvim_tree_ready(function()
  --   vim.cmd("NvimTreeRefresh")
  -- end)
end

function config.illuminate()
  vim.g.Illuminate_delay = 500
  vim.g.Illuminate_highlightUnderCursor = 1
  vim.g.Illuminate_ftblacklist = {'NvimTree'}
end

function config.gitsigns()
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

      -- ['n ]c'] = { expr = true, "&diff ? ']c' : '<cmd>lua require\"gitsigns\".next_hunk()<CR>'"},
      -- ['n [c'] = { expr = true, "&diff ? '[c' : '<cmd>lua require\"gitsigns\".prev_hunk()<CR>'"},

      -- ['n <leader>hs'] = '<cmd>lua require"gitsigns".stage_hunk()<CR>',
      -- ['n <leader>hu'] = '<cmd>lua requiregitsigns".undo_stage_hunk()<CR>',
      -- ['n <leader>hr'] = '<cmd>lua require"gitsigns".reset_hunk()<CR>',
      -- ['n <leader>hR'] = '<cmd>lua require"gitsigns".reset_buffer()<CR>',
      -- ['n <leader>hp'] = '<cmd>lua require"gitsigns".preview_hunk()<CR>',

      -- -- Text objects
      -- ['o ih'] = ':<C-U>lua require"gitsigns".select_hunk()<CR>',
      -- ['x ih'] = ':<C-U>lua require"gitsigns".select_hunk()<CR>'
    },
    watch_index = {
      interval = 1000
    },
    current_line_blame = false,
    sign_priority = 6,
    update_debounce = 100,
    status_formatter = nil, -- Use default
    use_decoration_api = true,
    use_internal_diff = true,  -- If luajit is present
  }
end

function config.theme()

  vim.g.tokyonight_style = "night"
  vim.g.tokyonight_italic_functions = true
  vim.g.tokyonight_italic_comments = true
  vim.g.tokyonight_dark_sidebar = false
  vim.g.tokyonight_dark_float = false
  vim.api.nvim_exec(
    [[
      colorscheme tokyonight
      hi default link EndOfLineSpace Substitute
      match EndOfLineSpace /\s\+$/
      hi EndOfBuffer ctermfg=11 guifg=#3b4261
      hi VertSplit ctermfg=11 guifg=#3b4261
    ]],
    false
  )
end

return config
