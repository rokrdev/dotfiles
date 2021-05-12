local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local make_entry = require('telescope.make_entry')
local conf = require('telescope.config').values
local Job = require('plenary.job')
local sorters = require('telescope.sorters')

local flatten = vim.tbl_flatten

local minimum_grep_characters = 2
local minimum_files_characters = 0

local use_highlighter = false

local custom = {}

function custom.find_files()
  opts = opts or {}

  local _ = make_entry.gen_from_vimgrep(opts)
  local live_grepper = finders._new {
    fn_command = function(self, prompt)
      if #prompt < minimum_files_characters then
        return nil
      end

      return {
        writer = Job:new {
          command = 'rg',
          args = {"--files", "--hidden"},
        },

        command = 'fzf',
        args = {'--filter', prompt}
      }
    end,

    entry_maker = make_entry.gen_from_file(opts),
  }

  pickers.new(opts, {
    prompt_title = 'Fzf Writer: Files',
    finder = live_grepper,
    previewer = conf.grep_previewer(opts),
    sorter = use_highlighter and sorters.highlighter_only(opts) or nil ,
  }):find()
end

function custom.grep_word_under_cursor()
  require('telescope.builtin').grep_string({
    word_match = '-w',
    only_sort_text = true,
    search = require('utils').getWordUnderCursor(), 
  })
end

function custom.grep_visual_selection()
  require('telescope.builtin').grep_string({
    word_match = '-w',
    only_sort_text = true,
    search = require('utils').getVisualSelection(), 
  })
end

function custom.git_conflicts(opts)
  opts.entry_maker = opts.entry_maker or make_entry.gen_from_file(opts)

  pickers.new(opts, {
    prompt_title = 'Git Conflicts',
    finder = finders.new_oneshot_job(
      vim.tbl_flatten({"git","diff","--name-only","--diff-filter=U"}),
      opts
    ),
    previewer = conf.file_previewer(opts),
    sorter = conf.file_sorter(opts),
  }):find()
end

return custom
