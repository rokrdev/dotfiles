require('keymap.commands').setup()
local bind = require('keymap.bind')
local map_cr = bind.map_cr
local map_cu = bind.map_cu
local map_cmd = bind.map_cmd
local map_cmd_cr= bind.map_cmd_cr
local map_args = bind.map_args

local plug_map = {
  -- normal
  ["n|<Leader>n"]             = map_cmd_cr("lua require('helpers').nnnPicker()"):with_noremap(),
  ["n|<Leader>b"]             = map_cr("Buffers"):with_noremap(),
  ["n|<Leader>o"]             = map_cr("Files"):with_noremap(),
  ["n|<Leader>f"]             = map_cr("RG"):with_noremap(),
  ["n|<Leader>F"]             = map_cr("RGRaw"):with_noremap(),
  ["n|<Leader>G"]             = map_cr("GF?"):with_noremap(),
  ["n|<Leader>*"]             = map_cmd_cr("lua require('helpers').rgWordUnderCursor()"):with_noremap(),
  ["n|sh"]                    = map_cu("call sneak#wrap('', 1, 0, 1, 2)"),
  ["n|sl"]                    = map_cu("call sneak#wrap('', 1, 1, 1, 2)"):with_noremap(),
  ["n|sH"]                    = map_cu("call sneak#wrap('', 1, 0, 0, 2)"):with_noremap(),
  ["n|sL"]                    = map_cu("call sneak#wrap('', 1, 1, 0, 2)"):with_noremap(),
  ["n|sj"]                    = map_cmd("<Plug>SneakLabel_s"),
  ["n|sk"]                    = map_cmd("<Plug>SneakLabel_S"),

  -- visual
  ["v|<Leader>*"]             = map_cmd_cr("lua require('helpers').rgVisualSelection()"):with_noremap(),
}

bind.nvim_load_mapping(plug_map)
