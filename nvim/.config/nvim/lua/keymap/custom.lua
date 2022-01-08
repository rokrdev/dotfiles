local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local builtin = require('telescope.builtin')
local make_entry = require('telescope.make_entry')
local conf = require('telescope.config').values

local f = {}

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

function f.custom_find(opts)
  builtin.find_files({
    prompt_title = opts.title,
    cwd = opts.loc,
    hidden = true,
  })
end

function f.custom_search(opts)
  builtin.live_grep({
    prompt_title = opts.title,
    cwd = opts.loc,
  })
end

function f.custom_grep(opts)
  builtin.grep_string({
    prompt_title = opts.title,
    search_dirs = {opts.loc},
  })
end

return f
