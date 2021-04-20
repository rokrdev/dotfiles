local bind = require('keymap.bind')
local map_cr = bind.map_cr
local map_cu = bind.map_cu
local map_cmd = bind.map_cmd
local map_lua= bind.map_lua
local map_args = bind.map_args
require('keymap.commands').setup()
require('keymap.config')

local plug_map = {
  -- normal
  -- fzf/rg
  ["n|<Leader>b"]             = map_cr("Buffers"):with_noremap(),
  ["n|<Leader>fo"]            = map_cr("Files"):with_noremap(),
  ["n|<Leader>ff"]            = map_cr("RG"):with_noremap(),
  ["n|<Leader>fF"]            = map_cr("RGRaw"):with_noremap(),
  ["n|<Leader>G"]             = map_cr("GF?"):with_noremap(),
  ["n|<Leader>fw"]            = map_lua("require('utils').rgWordUnderCursor()"):with_noremap(),
  -- nnn/scalpel/blame/nvimtree
  ["n|<Leader>fn"]             = map_lua("require('utils').nnnPicker()"):with_noremap(),
  ["n|<Leader>r"]             = map_cmd("<Plug>(Scalpel)"),
  ["n|gb"]                    = map_cr("GitMessenger"),
  ["n|<Leader>ft"]             = map_cr("NvimTreeToggle"):with_noremap(),
  -- sneak
  ["n|sh"]                    = map_cu("call sneak#wrap('', 1, 0, 1, 2)"):with_noremap(),
  ["n|sl"]                    = map_cu("call sneak#wrap('', 1, 1, 1, 2)"):with_noremap(),
  ["n|sH"]                    = map_cu("call sneak#wrap('', 1, 0, 0, 2)"):with_noremap(),
  ["n|sL"]                    = map_cu("call sneak#wrap('', 1, 1, 0, 2)"):with_noremap(),
  ["n|sj"]                    = map_cmd("<Plug>SneakLabel_s"),
  ["n|sk"]                    = map_cmd("<Plug>SneakLabel_S"),
  ["n|sr"]                    = map_cr("write | edit | TSBufEnable highlight"),
  -- bufferline
  ["n|<C-h>"]                 = map_cr("BufferLineCyclePrev"):with_noremap(),
  ["n|<C-l>"]                 = map_cr("BufferLineCycleNext"):with_noremap(),
  -- Plugin acceleratedjk
  ["n|j"]                     = map_cmd('v:lua.enhance_jk_move("j")'):with_silent():with_expr(),
  ["n|k"]                     = map_cmd('v:lua.enhance_jk_move("k")'):with_silent():with_expr(),

  -- visual
  ["v|<Leader>fw"]            = map_lua("require('utils').rgVisualSelection()"):with_noremap(),
  ["v|<Leader>r"]             = map_cmd("<Plug>(ScalpelVisual)"),

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
