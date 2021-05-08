local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local make_entry = require('telescope.make_entry')
local conf = require('telescope.config').values

local custom = {}

function custom.find_files()
  require('telescope.builtin').find_files({
    find_command = {'rg','--hidden','--files'},
  })
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
