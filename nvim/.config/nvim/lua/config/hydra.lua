local Hydra = require'hydra'

Hydra({
  name = 'Window',
  mode = 'n',
  hint = [[
  _h_: increase width   _j_: increase height   _v_: Split right   _b_: balance window
  _l_: decrease width   _k_: decrease height   _s_: Split down    _<Esc>_: quit
  ^
  ^
  ]],
  body = "<leader>w",
  config = {
    invoke_on_body = true,
    hint = {
      border = 'rounded'
    }
  },
  heads = {
    { 'h', ":vertical resize +5<CR>" },
    { 'l', ":vertical resize -5<CR>" },
    { 'j', ":resize +5<CR>" },
    { 'k', ":resize -5<CR>" },
    { 'b', ":wincmd =<CR>" },
    { 'v', ":FocusSplitRight<CR>", { exit = true } },
    { 's', ":FocusSplitDown<CR>", { exit = true } },
    { '<Esc>', nil,  { exit = true }},
  }
})
