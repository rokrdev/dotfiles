local Hydra = require'hydra'
print('hydra setup')

Hydra({
  name = 'Window',
  mode = 'n',
  body = "<leader>w",
  config = {
    invoke_on_body = true,
    hint = {
      border = 'rounded'
    }
  },
  heads = {
    { 'h', ":vertical resize +5<CR>", { desc = "increase width" } },
    { 'l', ":vertical resize -5<CR>", { desc = "decrease width" } },
    { 'j', ":resize +5<CR>", { desc = "increase height" } },
    { 'k', ":resize -5<CR>", { desc = "decrease height" } },
    { 'b', ":wincmd =<CR>", { desc = "balance all splits" } },
    { 'x', ":on<CR>", { desc = "unsplit" } },
    { 'v', ":FocusSplitRight<CR>", { exit = true, desc = "split vertically" } },
    { 's', ":FocusSplitDown<CR>", { exit = true, desc = "split horizontally" } },
    { '<Esc>', nil,  { exit = true }},
  }
})
