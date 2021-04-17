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
  ["n|<Leader>o"]             = map_cr("Files"):with_noremap(),
  ["n|<Leader>f"]             = map_cr("RG"):with_noremap(),
  ["n|<Leader>F"]             = map_cr("RGRaw"):with_noremap(),
  ["n|<Leader>G"]             = map_cr("GF?"):with_noremap(),
  ["n|<Leader>*"]             = map_lua("require('helpers').rgWordUnderCursor()"):with_noremap(),
  -- nnn/scalpel/blame/nvimtree
  ["n|<Leader>n"]             = map_lua("require('helpers').nnnPicker()"):with_noremap(),
  ["n|<Leader>e"]             = map_cmd("<Plug>(Scalpel)"),
  ["n|gb"]                    = map_cr("GitMessenger"),
  ["n|<Leader>t"]             = map_cr("NvimTreeToggle"):with_noremap(),
  -- sneak
  ["n|sh"]                    = map_cu("call sneak#wrap('', 1, 0, 1, 2)"):with_noremap(),
  ["n|sl"]                    = map_cu("call sneak#wrap('', 1, 1, 1, 2)"):with_noremap(),
  ["n|sH"]                    = map_cu("call sneak#wrap('', 1, 0, 0, 2)"):with_noremap(),
  ["n|sL"]                    = map_cu("call sneak#wrap('', 1, 1, 0, 2)"):with_noremap(),
  ["n|sj"]                    = map_cmd("<Plug>SneakLabel_s"),
  ["n|sk"]                    = map_cmd("<Plug>SneakLabel_S"),
  -- bufferline
  ["n|<C-h>"]                 = map_cr("BufferLineCyclePrev"):with_noremap(),
  ["n|<C-l>"]                 = map_cr("BufferLineCycleNext"):with_noremap(),
  -- Plugin acceleratedjk
  ["n|j"]                     = map_cmd('v:lua.enhance_jk_move("j")'):with_silent():with_expr(),
  ["n|k"]                     = map_cmd('v:lua.enhance_jk_move("k")'):with_silent():with_expr(),

  -- visual
  ["v|<Leader>*"]             = map_lua("require('helpers').rgVisualSelection()"):with_noremap(),
  ["v|<Leader>e"]             = map_cmd("<Plug>(ScalpelVisual)"),

  -- insert
  ["i|<Tab>"]                 = map_cmd("v:lua.tab_complete()"):with_silent():with_expr(),
  ["i|<S-Tab>"]               = map_cmd("v:lua.s_tab_complete()"):with_silent():with_expr(),
  ["i|<C-f>"]                 = map_cmd("v:lua.snippet_expand()"):with_silent():with_expr(),

  -- select
  ["s|<Tab>"]                 = map_cmd("v:lua.tab_complete()"):with_silent():with_expr(),
  ["s|<S-Tab>"]               = map_cmd("v:lua.s_tab_complete()"):with_silent():with_expr(),
}

bind.nvim_load_mapping(plug_map)
