local config = {}

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

-- function config.telescope()
--   if not packer_plugins['plenary.nvim'].loaded then
--     vim.cmd [[packadd plenary.nvim]]
--     vim.cmd [[packadd popup.nvim]]
--     vim.cmd [[packadd telescope-fzf-writer.nvim]]
--   end

--   local actions = require('telescope.actions')
--   require('telescope').setup {
--     defaults = {
--       vimgrep_arguments = {
--         'rg',
--         '--color=never',
--         '--hidden',
--         '--no-heading',
--         '--with-filename',
--         '--line-number',
--         '--column',
--         '--smart-case'
--       },
--       mappings = {
--         i = {
--           ["<esc>"] = actions.close,
--           ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
--         },
--       },
--       prompt_prefix = '🔭 ',
--       prompt_position = 'bottom',
--       selection_caret = " ",
--       sorting_strategy = 'descending',
--       results_width = 0.6,
--       file_previewer = require'telescope.previewers'.vim_buffer_cat.new,
--       grep_previewer = require'telescope.previewers'.vim_buffer_vimgrep.new,
--       qflist_previewer = require'telescope.previewers'.vim_buffer_qflist.new,
--     },
--     extensions = {
--       extensions = {
--         fzf_writer = {
--           use_highlighter = true,
--         }
--       }
--     }
--   }
--   -- require('telescope').load_extension('fzf')
--   vim.cmd([[packadd cfilter]])
-- end

function config.easymotion()
  vim.g.EasyMotion_smartcase = 1
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
    { "<Leader>fg", vimgrep {}},
    { "<Leader>fw", vimgrep { filter_with = "cword" }},
    { "<Leader>fw", vimgrep { filter_with = "selection" },  { modes = { "x" } }},
    { "<Leader>b", snap.config.file {producer = "vim.buffer"}},
   -- { "<Leader>gc", snap.config.file {
   --   producer = "git.file",
   --   args = {"diff","--name-only","--diff-filter=U"}
   --   reverse = true,
   -- }},
  }
  vim.cmd([[packadd cfilter]])
end

return config
