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
      buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
      buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
      buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
      buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
      buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
      buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
      buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
      buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
      buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
      buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

      -- Set some keybinds conditional on server capabilities
      -- if client.server_capabilities.documentFormattingProvider then
      --   buf_set_keymap("n", "<space>cf", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
      -- elseif client.resolved_capabilities.document_range_formatting then
      --   buf_set_keymap("n", "<space>cf", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
      -- end

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

    local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
    capabilities.textDocument.completion.completionItem.snippetSupport = true

    local servers = { "dockerls", "html", "jdtls", "jsonls", "kotlin_language_server", "pyright", "sqls", "tsserver", "yamlls"}
    require("nvim-lsp-installer").setup {
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
            globals = { 'vim' }
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
    local cmp = require'cmp'

    local has_words_before = function()
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    end

    local feedkey = function(key, mode)
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
    end

    cmp.setup({
      snippet = {
        expand = function(args)
          vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        end,
      },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      mapping = {
        ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ['<Down>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
        ['<Up>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif vim.fn["vsnip#available"](1) == 1 then
            feedkey("<Plug>(vsnip-expand-or-jump)", "")
          elseif has_words_before() then
            cmp.complete()
          else
            fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function()
          if cmp.visible() then
            cmp.select_prev_item()
          elseif vim.fn["vsnip#jumpable"](-1) == 1 then
            feedkey("<Plug>(vsnip-jump-prev)", "")
          end
        end, { "i", "s" }),
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.close(),
        ['<CR>'] = cmp.mapping.confirm({
          behavior = cmp.ConfirmBehavior.Replace,
          select = true,
        })
      },
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'nvim_lsp_signature_help' },
        { name = 'vsnip' }, -- For vsnip users.
      }, {
        { name = 'buffer' },
      })
    })

    -- Set configuration for specific filetype.
    cmp.setup.filetype('gitcommit', {
      sources = cmp.config.sources({
        { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
      }, {
        { name = 'buffer' },
      })
    })

    -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline('/', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = 'buffer' }
      }
    })

    -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline(':', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = 'path' }
      }, {
        { name = 'cmdline' }
      })
    })

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
    if packer_plugins['diffview.nvim'] and not packer_plugins['diffview.nvim'].loaded then
      vim.cmd [[packadd diffview.nvim]]
    end
    local neogit = require'neogit'
    neogit.setup {
      disable_signs = false,
      disable_hint = false,
      disable_context_highlighting = false,
      disable_commit_confirmation = false,
      auto_refresh = true,
      disable_builtin_notifications = false,
      use_magit_keybindings = true,
      commit_popup = {
        kind = "split",
      },
      -- Change the default way of opening neogit
      kind = "tab",
      -- customize displayed signs
      signs = {
        -- { CLOSED, OPENED }
        section = { ">", "v" },
        item = { ">", "v" },
        hunk = { "", "" },
      },
      integrations = {
        diffview = true,
      },
      -- override/add mappings
      mappings = {
        -- modify status buffer mappings
        status = {
          -- Adds a mapping with "B" as key that does the "BranchPopup" command
          ["B"] = "BranchPopup",
        }
      },
    }
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
    require('nvim-treesitter.configs').setup {
      ensure_installed = {
        "bash",
        "c",
        "clojure",
        "commonlisp",
        "cpp",
        "css",
        "dockerfile",
        "eex",
        "elixir",
        "fennel",
        "fish",
        "go",
        "graphql",
        "html",
        "http",
        "java",
        "javascript",
        "jsdoc",
        "json",
        "json5",
        "kotlin",
        "lua",
        "make",
        "markdown",
        "php",
        "python",
        "regex",
        "rst",
        "ruby",
        "rust",
        "scss",
        "svelte",
        "swift",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vue",
        "yaml"
      },
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
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')
    local telescope_custom_actions = {}

    function telescope_custom_actions._multiopen(prompt_bufnr, open_cmd)
        local picker = action_state.get_current_picker(prompt_bufnr)
        local selected_entry = action_state.get_selected_entry()
        local num_selections = #picker:get_multi_selection()
        if not num_selections or num_selections <= 1 then
            actions.add_selection(prompt_bufnr)
        end
        actions.send_selected_to_qflist(prompt_bufnr)
        vim.cmd("silent cfdo " .. open_cmd)
    end

    function telescope_custom_actions.multi_selection_open(prompt_bufnr)
        telescope_custom_actions._multiopen(prompt_bufnr, "edit")
    end

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
            ["<TAB>"] = actions.toggle_selection,
            ["<CR>"] = telescope_custom_actions.multi_selection_open,
          },
        },
        sorting_strategy = 'descending',
        file_previewer = require'telescope.previewers'.vim_buffer_cat.new,
        grep_previewer = require'telescope.previewers'.vim_buffer_vimgrep.new,
        qflist_previewer = require'telescope.previewers'.vim_buffer_qflist.new,
      },
      pickers = {
        find_files = { no_ignore = false },
      },
      extensions = {
        fzf = {
          fuzzy = true,                    -- false will only do exact matching
          override_generic_sorter = true,  -- override the generic sorter
          override_file_sorter = true,     -- override the file sorter
          case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
          -- the default case_mode is "smart_case"
        }
      }
    }
    vim.cmd([[packadd cfilter]])
  end
}

plugins['lewis6991/gitsigns.nvim'] = {
  event = 'VimEnter',
  requires = {'nvim-lua/plenary.nvim'},
  config = function ()
    require('gitsigns').setup {
      numhl = false,
      linehl = false,
      keymaps = {
        -- Default keymap options
        noremap = true,
        buffer = true,
        ['n ]c'] = { expr = true, "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'"},
        ['n [c'] = { expr = true, "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'"},

        -- ['n <leader>hs'] = '<cmd>lua require"gitsigns".stage_hunk()<CR>',
        -- ['n <leader>hu'] = '<cmd>lua requiregitsigns".undo_stage_hunk()<CR>',
        -- ['n <leader>hr'] = '<cmd>lua require"gitsigns".reset_hunk()<CR>',
        -- ['n <leader>hR'] = '<cmd>lua require"gitsigns".reset_buffer()<CR>',
        -- ['n <leader>hp'] = '<cmd>lua require"gitsigns".preview_hunk()<CR>',

        -- Text objects
        ['o ih'] = ':<C-U>lua require"gitsigns".select_hunk()<CR>',
        ['x ih'] = ':<C-U>lua require"gitsigns".select_hunk()<CR>'
      },
      watch_gitdir = {
        interval = 1000,
        follow_files = true,
      },
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
      },
      sign_priority = 6,
      update_debounce = 100,
      status_formatter = nil, -- Use default
    }
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
    require'statusline'
    -- require('lualine').setup{
    --   options = {
    --     theme = 'tokyonight',
    --     icons_enabled = true,
    --     component_separators = '',
    --     section_separators = '',
    --     globalstatus = true
    --   },
    --   sections = {
    --     lualine_a = { 'mode' },
    --     lualine_b = { 'branch' },
    --     lualine_c = {
    --       'filename',
    --       {'diagnostics', sources = {'nvim_diagnostic', "nvim_lsp"}, sections = {'error', 'warn'}},
    --       'diff',
    --     },
    --     lualine_x = { 'encoding', 'fileformat', 'filetype' },
    --     lualine_y = { 'location' },
    --     lualine_z = { 'progress' },
    --   },
    --   inactive_sections = {
    --     lualine_a = {  },
    --     lualine_b = { 'branch' },
    --     lualine_c = { 'filename' },
    --     lualine_x = {  },
    --     lualine_y = {  },
    --     lualine_z = { 'location' }
    --   },
    --   extensions = {
    --     'nvim-tree',
    --     'quickfix',
    --   }
    -- }
  end
}

plugins['kyazdani42/nvim-tree.lua'] = {
  event = 'VimEnter',
  config = function ()
    require('nvim-tree').setup {
      git = { enable = false },
      disable_netrw       = true,
      hijack_netrw        = true,
      update_cwd          = true,
      update_focused_file = {
        enable      = true,
        update_cwd  = false,
        ignore_list = {}
      },
      view = {
        width = 30,
        side = 'left',
      },
      renderer = {
        indent_markers = {
          enable = true,
          icons = {
            corner = "└ ",
            edge = "│ ",
            none = "  ",
          },
        },
        icons = {
          glyphs = {
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
        }
      },
    }
  end
}

plugins['goolord/alpha-nvim'] = {
  config = function ()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

  -- Set heade
  -- dashboard.section.header.val = {
    --   "                                                     ",
    --   "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
    --   "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
    --   "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
    --   "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
    --   "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
    --   "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
    --   "                                                     ",
    -- }

    dashboard.section.header.val = {
      "   ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣿⣶⣿⣦⣼⣆          ",
      "    ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡠⢾⣿⣿⡿⠋⠉⠉⠻⣿⣿⡛⣦       ",
      "          ⠈⢿⣿⣟⠦ ⣾⣿⣿⣷    ⠻⠿⢿⣿⣧⣄     ",
      "           ⣸⣿⣿⢧ ⢻⠻⣿⣿⣷⣄⣀⠄⠢⣀⡀⠈⠙⠿⠄    ",
      "          ⢠⣿⣿⣿⠈    ⣻⣿⣿⣿⣿⣿⣿⣿⣛⣳⣤⣀⣀   ",
      "   ⢠⣧⣶⣥⡤⢄ ⣸⣿⣿⠘  ⢀⣴⣿⣿⡿⠛⣿⣿⣧⠈⢿⠿⠟⠛⠻⠿⠄  ",
      "  ⣰⣿⣿⠛⠻⣿⣿⡦⢹⣿⣷   ⢊⣿⣿⡏  ⢸⣿⣿⡇ ⢀⣠⣄⣾⠄   ",
      " ⣠⣿⠿⠛ ⢀⣿⣿⣷⠘⢿⣿⣦⡀ ⢸⢿⣿⣿⣄ ⣸⣿⣿⡇⣪⣿⡿⠿⣿⣷⡄  ",
      " ⠙⠃   ⣼⣿⡟  ⠈⠻⣿⣿⣦⣌⡇⠻⣿⣿⣷⣿⣿⣿ ⣿⣿⡇ ⠛⠻⢷⣄ ",
      "      ⢻⣿⣿⣄   ⠈⠻⣿⣿⣿⣷⣿⣿⣿⣿⣿⡟ ⠫⢿⣿⡆     ",
      "       ⠻⣿⣿⣿⣿⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⡟⢀⣀⣤⣾⡿⠃     ",
    }
    -- Set menu
    dashboard.section.buttons.val = {
      dashboard.button( "e", "> New file", ":ene<CR>"),
      dashboard.button( "SPC f f", "> Find file", ":Telescope find_files hidden=true<CR>"),
      dashboard.button( "SPC f s", "> Search word", ":Telescope live_grep<CR>"),
      dashboard.button( "SPC f n", "> Directory", ":NnnPicker<CR>"),
      dashboard.button( "SPC f o", "> Recent", ":Telescope oldfiles<CR>"),
      dashboard.button( "SPC f t", "> Tree", ":NvimTreeToggle<CR>"),
      dashboard.button( "SPC h f", "> Dotfiles", ":Dff<CR>"),
      dashboard.button( "SPC h s", "> Dotfiles Search", ":Dfs<CR>"),
      dashboard.button( "SPC z f", "> Zettelkastan", ":lua require('telekasten').find_notes()<CR>"),
      dashboard.button( "q", "> Quit NVIM", ":qa<CR>"),
    }

    alpha.setup(dashboard.opts)
  end
}

plugins["renerocksai/telekasten.nvim"] = {
  event = 'VimEnter',
  config = function ()
    local home = vim.fn.expand("~/zettelkasten")
    require('telekasten').setup({
      home         = home,
      take_over_my_home = true,
      auto_set_filetype = true,

      -- dir names for special notes (absolute path or subdir name)
      dailies      = home .. '/' .. 'daily',
      weeklies     = home .. '/' .. 'weekly',
      templates    = home .. '/' .. 'templates',

      image_subdir = "img",

      extension    = ".md",

      prefix_title_by_uuid = false,
      uuid_type = "%Y%m%d%H%M",
      uuid_sep = "-",

      follow_creates_nonexisting = true,
      dailies_create_nonexisting = true,
      weeklies_create_nonexisting = true,

      template_new_note = home .. '/' .. 'templates/new_note.md',

      template_new_daily = home .. '/' .. 'templates/daily.md',

      template_new_weekly= home .. '/' .. 'templates/weekly.md',

      image_link_style = "markdown",

      -- integrate with calendar-vim
      plug_into_calendar = true,
      calendar_opts = {
        weeknm = 4,
        calendar_monday = 1,
        calendar_mark = 'left-fit',
      },

      close_after_yanking = false,
      insert_after_inserting = true,
      tag_notation = "#tag",
      command_palette_theme = "dropdown",

      show_tags_theme = "dropdown",

      subdirs_in_links = true,

      template_handling = "smart",
      new_note_location = "smart",

      rename_update_links = true,
    })
  end
}

plugins["mattn/calendar-vim"] = {
  event = 'VimEnter',
}

return plugins
