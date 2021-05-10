local bind = require('keymap.bind')
local map_cr = bind.map_cr
local map_cu = bind.map_cu
local map_cmd = bind.map_cmd
local map_lua= bind.map_lua
local map_args = bind.map_args
local map_wait = bind.map_wait
require('keymap.commands').setup()
require('keymap.config')

local plug_map = {
  -- normal
  -- fzf/rg
  ["n|<Leader>b"]             = map_cr("Telescope buffers"):with_noremap():with_nowait(),
  ["n|<Leader>ff"]            = map_lua("require'keymap.custom'.find_files{}"):with_noremap():with_nowait(),
  ["n|<Leader>fs"]            = map_cr("Telescope live_grep"):with_noremap():with_nowait(),
  -- ["n|<Leader>fS"]            = map_wait("RGRaw "):with_noremap():with_nowait(),
  ["n|<Leader>gc"]            = map_lua("require'keymap.custom'.git_conflicts{}"):with_noremap():with_nowait(),
  ["n|<Leader>fw"]            = map_lua("require'keymap.custom'.grep_word_under_cursor{}"):with_noremap():with_nowait(),
  -- nnn/scalpel/blame/nvimtree
  ["n|<Leader>fn"]            = map_lua("require('utils').nnnPicker()"):with_noremap():with_nowait(),
  ["n|<Leader>ft"]            = map_cr("NvimTreeToggle"):with_noremap():with_nowait(),
  ["n|<Leader>fc"]            = map_cr("Scratch"):with_noremap():with_nowait(),
  ["n|<Leader>fr"]            = map_cmd("<Plug>(Scalpel)"):with_nowait(),
  ["n|<Leader>gl"]            = map_lua("require'gitsigns'.blame_line()"):with_noremap():with_nowait(),
  -- sneak
  ["n|sh"]                    = map_cu("call sneak#wrap('', 1, 0, 1, 2)"):with_noremap():with_nowait(),
  ["n|sl"]                    = map_cu("call sneak#wrap('', 1, 1, 1, 2)"):with_noremap():with_nowait(),
  ["n|sH"]                    = map_cu("call sneak#wrap('', 1, 0, 0, 2)"):with_noremap():with_nowait(),
  ["n|sL"]                    = map_cu("call sneak#wrap('', 1, 1, 0, 2)"):with_noremap():with_nowait(),
  ["n|sj"]                    = map_cmd("<Plug>SneakLabel_s"):with_nowait(),
  ["n|sk"]                    = map_cmd("<Plug>SneakLabel_S"):with_nowait(),
  ["n|<Leader>t;"]            = map_cr("write | edit | TSBufEnable highlight"):with_nowait():with_silent(),
  -- bufferline
  ["n|<C-h>"]                 = map_cr("BufferLineCyclePrev"):with_noremap():with_silent():with_nowait(),
  ["n|<C-l>"]                 = map_cr("BufferLineCycleNext"):with_noremap():with_silent():with_nowait(),
  -- Plugin acceleratedjk
  ["n|j"]                     = map_cmd('v:lua.enhance_jk_move("j")'):with_silent():with_expr(),
  ["n|k"]                     = map_cmd('v:lua.enhance_jk_move("k")'):with_silent():with_expr(),

  -- visual
  ["v|<Leader>fw"]            = map_lua("require'keymap.custom'.grep_visual_selection{}"):with_noremap():with_nowait(),
  ["v|<Leader>fr"]            = map_cmd("<Plug>(ScalpelVisual)"):with_nowait(),

  -- insert
  ["i|<Tab>"]                 = map_cmd("v:lua.tab_complete()"):with_silent():with_expr(),
  ["i|<S-Tab>"]               = map_cmd("v:lua.s_tab_complete()"):with_silent():with_expr(),
  ["i|<C-f>"]                 = map_cmd("v:lua.snippet_expand()"):with_silent():with_expr(),
  ["i|<CR>"]                  = map_cmd("v:lua.completion_confirm()"):with_noremap():with_expr():with_silent(),

  -- select
  ["s|<Tab>"]                 = map_cmd("v:lua.tab_complete()"):with_silent():with_expr(),
  ["s|<S-Tab>"]               = map_cmd("v:lua.s_tab_complete()"):with_silent():with_expr(),
}

bind.nvim_load_mapping(plug_map)
