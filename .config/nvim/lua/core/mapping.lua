local bind = require('keymap.bind')
local map_cr = bind.map_cr
local map_cu = bind.map_cu
local map_cmd = bind.map_cmd
local map_args = bind.map_args
local map_wait = bind.map_wait
local map_lua = bind.map_lua

vim.g["@z"] = "f cl<CR><ESC>l"

local def_map = {
  -- normal mode
  ["n|s"]                    = map_cmd("<Nop>"),
  ["n|<M-j>"]                = map_cmd(":m .+1<CR>=="):with_noremap():with_silent():with_nowait(),
  ["n|<M-k>"]                = map_cmd(":m .-2<CR>=="):with_noremap():with_silent():with_nowait(),
  ["n|s-"]                   = map_cr("bd"):with_noremap():with_nowait(),
  ["n|s_"]                   = map_cr("bd!"):with_noremap():with_nowait(),
  ["n|sp"]                   = map_cmd("\"+p"):with_noremap():with_nowait(),
  ["n|s;"]                   = map_cr("b#"):with_noremap():with_nowait(),
  ["n|sc"]                   = map_cr("nohl"):with_noremap():with_silent():with_nowait(),
  -- ["n|s#"]                   = map_cmd(":let @/='\\<'.expand('<cword>').'\\>'<CR>cgN"):with_noremap():with_silent(),
  -- ["n|s*"]                   = map_cmd(":let @/='\\<'.expand('<cword>').'\\>'<CR>cgn"):with_noremap():with_silent(),
  ["n|ss"]                   = map_args("ls<CR>:b"):with_noremap():with_nowait(),
  ["n|s!"]                   = map_cr(":let @+=expand('%')"):with_noremap():with_nowait(),
  ["n|sn"]                   = map_lua("require('utils').toggleNumbers()"):with_noremap():with_nowait(),
  ["n|sq"]                   = map_cmd("q"):with_noremap():with_nowait(),
  ["n|q"]                    = map_cmd("<Nop>"):with_noremap(),
  ["n|<M-+>"]                = map_cr(":vertical resize +5"):with_noremap():with_silent(),
  ["n|<M-=>"]                = map_cr(":vertical resize -5"):with_noremap():with_silent(),
  ["n|<M-->"]                = map_cr(":resize -5"):with_noremap():with_silent(),
  ["n|<M-_>"]                = map_cr(":resize +5"):with_noremap():with_silent(),
  ["n|!"]                    = map_cmd(vim.g["@z"]):with_noremap():with_nowait(),
  ["n|<C-e>"]                = map_cr("wincmd w"):with_noremap():with_nowait(),
  ["n|<Leader>gg"]           = map_lua("require('utils').openTerm('tig status')"):with_noremap():with_nowait(),
  ["n|<Leader>gb"]           = map_lua("require('utils').openTerm('tig ' .. vim.fn.expand('%'))"):with_noremap():with_nowait(),
  ["n|<Leader>gl"]           = map_lua("require('utils').openTerm('tig')"):with_noremap():with_nowait(),
  ["n|<Leader>ss"]           = map_args("SS"):with_noremap(),
  ["n|<Leader>sr"]           = map_wait("SR " .. require('utils').getSessionFilePath()):with_noremap(),
  ["n|<Leader>sd"]           = map_wait("SD " .. require('utils').getSessionFilePath()):with_noremap(),
  ["n|<Leader>fc"]           = map_cr("Scratch"):with_noremap():with_nowait(),
  ["n|<Leader>sp"]           = map_cr("let @+ = expand('%')"):with_noremap(),
  ["n|sm"]                   = map_cmd("\"mp"):with_noremap():with_nowait(),

  -- visual mode
  ["v|s"]                    = map_cmd("<Nop>"),
  ["v|<M-j>"]                = map_cmd(":m '>+1<CR>gv=gv"):with_noremap():with_nowait(),
  ["v|<M-k>"]                = map_cmd(":m '<-2<CR>gv=gv"):with_noremap():with_nowait(),
  ["v|sy"]                   = map_cmd("\"+y"):with_noremap():with_nowait(),
  ["v|sp"]                   = map_cmd("\"+p"):with_noremap():with_nowait(),
  ["v|sM"]                   = map_cmd("\"my"):with_noremap():with_nowait(),
  ["v|sm"]                   = map_cmd("\"mp"):with_noremap():with_nowait(),
  -- ["v|s#"]                   = map_cmd("\"sy:let @/=@s<CR>cgN"):with_noremap(),
  -- ["v|s*"]                   = map_cmd("\"sy:let @/=@s<CR>cgn"):with_noremap(),
  ["v|*"]                    = map_cmd("lua require('utils').VSetSearch('/')<CR>/<C-R>=@/<CR>"):with_noremap():with_nowait(),
  ["v|#"]                    = map_cmd("lua require('utils').VSetSearch('?')<CR>/<C-R>=@/<CR>"):with_noremap():with_nowait(),

}

bind.nvim_load_mapping(def_map)

