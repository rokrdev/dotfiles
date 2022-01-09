local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local builtin = require('telescope.builtin')
local make_entry = require('telescope.make_entry')
local conf = require('telescope.config').values

local f = {}

function f.git_conflicts(opts)
  builtin.find_files({
    prompt_title = 'Git Conflicts',
    hidden = true,
    find_command = {"git","diff","--name-only","--diff-filter=U"},
  })
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
