-- local pickers = require('telescope.pickers')
-- local finders = require('telescope.finders')
-- local make_entry = require('telescope.make_entry')
-- local conf = require('telescope.config').values
-- local Job = require('plenary.job')
-- local sorters = require('telescope.sorters')

-- local flatten = vim.tbl_flatten

-- local minimum_grep_characters = 2
-- local minimum_files_characters = 0

-- local use_highlighter = true

local f = {}

local snap = require'snap'
local general = snap.get("producer.ripgrep.general")
local limit = snap.get'consumer.limit'
local select_vimgrep = snap.get'select.vimgrep'
local preview_vimgrep = snap.get'preview.vimgrep'
local git_general = snap.get'producer.git.general'
local producer_buffer = snap.get'producer.vim.buffer'
local file_select = snap.get'select.file'
local file_preview = snap.get'preview.file'
local fzf = snap.get'consumer.fzf'

local ripgrep_producer = function(request)
  local cwd = snap.sync(vim.fn.getcwd)
  return general(request, {
    args = {
      '--color=never',
      '--hidden',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '-w',
      request.filter
    },
    cwd = cwd
  })
end

function f.custom_grep(query)
  snap.run {
    reverse = true,
    prompt = 'Grep>',
    producer = limit(500, ripgrep_producer),
    select = select_vimgrep.select,
    multiselect = select_vimgrep.multiselect,
    initial_filter = query,
    views = {preview_vimgrep}
  }
end

-- function f.custom_grep(word)
--   opts = opts or {}

--   local live_grepper = finders._new {
--     fn_command = function(_, prompt)
--       local rg_args = flatten { conf.vimgrep_arguments, "-w", word }
--       table.remove(rg_args, 1)

--       return {
--         writer = Job:new {
--           command = 'rg',
--           args = rg_args,
--         },

--         command = 'fzf',
--         args = {'--filter', prompt},
--       }
--     end,

--     entry_maker = make_entry.gen_from_vimgrep(opts),
--   }

--   pickers.new(opts, {
--     prompt_title = 'Fzf Writer: Grep',
--     finder = live_grepper,
--     previewer = conf.grep_previewer(opts),
--     sorter = use_highlighter and sorters.highlighter_only(opts) or nil,
--   }):find()
-- end

-- nvim_dir = function(request)
--   return general(request, {
--     args = {"--hidden", "--line-buffered", "--files"},
--     cwd = snap.sync(vim.fn.getcwd)
--   })
-- end

function f.find_files()
  snap.run {
    reverse = true,
    prompt = 'Files>',
    producer = limit(500, snap.get 'consumer.fzf'(function(request)
      local cwd = snap.sync(vim.fn.getcwd)
      return general(request, {
        args = {"--hidden", "--line-buffered", "--files"},
        cwd = cwd
      })
    end)),
    select = file_select.select,
    multiselect = file_select.multiselect,
    views = {file_preview}
  }
end

function f.live_grep()
  snap.run {
    reverse = true,
    prompt = 'Live Grep>',
    producer = limit(500, ripgrep_producer),
    select = select_vimgrep.select,
    multiselect = select_vimgrep.multiselect,
    views = {preview_vimgrep}
  }
end

-- function f.find_files()
--   opts = opts or {}

--   local _ = make_entry.gen_from_vimgrep(opts)
--   local live_grepper = finders._new {
--     fn_command = function(self, prompt)
--       if #prompt < minimum_files_characters then
--         return nil
--       end

--       return {
--         writer = Job:new {
--           command = 'rg',
--           args = {"--files", "--hidden"},
--         },

--         command = 'fzf',
--         args = {'--filter', prompt}
--       }
--     end,

--     entry_maker = make_entry.gen_from_file(opts),
--   }

--   pickers.new(opts, {
--     prompt_title = 'Fzf Writer: Files',
--     finder = live_grepper,
--     previewer = conf.grep_previewer(opts),
--     sorter = use_highlighter and sorters.highlighter_only(opts) or nil ,
--   }):find()
-- end

function f.grep_word_under_cursor()
  f.custom_grep(require('utils').getWordUnderCursor())
end

function f.grep_visual_selection()
  f.custom.custom_grep(require('utils').getVisualSelection())
end

local git_conflict_producer = function(request)
  local cwd = snap.sync(vim.fn.getcwd)
  return git_general(request, {args = {"diff","--name-only","--diff-filter=U"}, cwd = cwd})
end

function f.git_conflicts()
  snap.run {
    reverse = true,
    prompt = 'Git Conflicts>',
    producer = snap.get'consumer.fzf'(git_conflict_producer),
    select = file_select.select,
    multiselect = file_select.multiselect,
    views = {file_preview}
  }
end

-- function f.git_conflicts(opts)
--   opts.entry_maker = opts.entry_maker or make_entry.gen_from_file(opts)

--   pickers.new(opts, {
--     prompt_title = 'Git Conflicts',
--     finder = finders.new_oneshot_job(
--       vim.tbl_flatten({"git","diff","--name-only","--diff-filter=U"}),
--       opts
--     ),
--     previewer = conf.file_previewer(opts),
--     sorter = conf.file_sorter(opts),
--   }):find()
-- end

function f.buffers()
  snap.run({
    reverse = true,
    prompt = 'Buffers>',
    producer = fzf(producer_buffer),
    select = file_select.select,
    multiselect = file_select.multiselect,
    views = {preview_file}
  })
end

return f
