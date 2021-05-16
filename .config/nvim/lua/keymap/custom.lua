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

local f = {}

function f.custom_grep(word)
  opts = opts or {}

  local live_grepper = finders._new {
    fn_command = function(_, prompt)
      local rg_args = flatten { conf.vimgrep_arguments, "-w", word }
      table.remove(rg_args, 1)

      return {
        writer = Job:new {
          command = 'rg',
          args = rg_args,
        },

        command = 'fzf',
        args = {'--filter', prompt},
      }
    end,

    entry_maker = make_entry.gen_from_vimgrep(opts),
  }

  pickers.new(opts, {
    prompt_title = 'Fzf Writer: Grep',
    finder = live_grepper,
    previewer = conf.grep_previewer(opts),
    sorter = use_highlighter and sorters.highlighter_only(opts) or nil,
  }):find()
end

function f.find_files()
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

function f.grep_word_under_cursor()
  f.custom_grep(require('utils').getWordUnderCursor())
end

function f.grep_visual_selection()
  f.custom.custom_grep(require('utils').getVisualSelection())
end

function f.git_conflicts(opts)
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

return f
