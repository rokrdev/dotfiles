local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

-- Set heade
-- dashboard.section.header.val = {
--   "                                                     ",
--   "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
--   "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
--   "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
--   "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
--   "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
--   "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
--   "                                                     ",
-- }

dashboard.section.header.val = {
  "   ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣿⣶⣿⣦⣼⣆          ",
  "    ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡠⢾⣿⣿⡿⠋⠉⠉⠻⣿⣿⡛⣦       ",
  "          ⠈⢿⣿⣟⠦ ⣾⣿⣿⣷    ⠻⠿⢿⣿⣧⣄     ",
  "           ⣸⣿⣿⢧ ⢻⠻⣿⣿⣷⣄⣀⠄⠢⣀⡀⠈⠙⠿⠄    ",
  "          ⢠⣿⣿⣿⠈    ⣻⣿⣿⣿⣿⣿⣿⣿⣛⣳⣤⣀⣀   ",
  "   ⢠⣧⣶⣥⡤⢄ ⣸⣿⣿⠘  ⢀⣴⣿⣿⡿⠛⣿⣿⣧⠈⢿⠿⠟⠛⠻⠿⠄  ",
  "  ⣰⣿⣿⠛⠻⣿⣿⡦⢹⣿⣷   ⢊⣿⣿⡏  ⢸⣿⣿⡇ ⢀⣠⣄⣾⠄   ",
  " ⣠⣿⠿⠛ ⢀⣿⣿⣷⠘⢿⣿⣦⡀ ⢸⢿⣿⣿⣄ ⣸⣿⣿⡇⣪⣿⡿⠿⣿⣷⡄  ",
  " ⠙⠃   ⣼⣿⡟  ⠈⠻⣿⣿⣦⣌⡇⠻⣿⣿⣷⣿⣿⣿ ⣿⣿⡇ ⠛⠻⢷⣄ ",
  "      ⢻⣿⣿⣄   ⠈⠻⣿⣿⣿⣷⣿⣿⣿⣿⣿⡟ ⠫⢿⣿⡆     ",
  "       ⠻⣿⣿⣿⣿⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⡟⢀⣀⣤⣾⡿⠃     ",
}
-- Set menu
dashboard.section.buttons.val = {
  dashboard.button("e", "> New file", ":ene<CR>"),
  dashboard.button("SPC f f", "> Find file", ":Telescope find_files hidden=true<CR>"),
  dashboard.button("SPC f s", "> Search word", ":Telescope live_grep<CR>"),
  dashboard.button("SPC f n", "> Directory", ":NnnPicker<CR>"),
  dashboard.button("SPC f o", "> Recent", ":Telescope oldfiles<CR>"),
  dashboard.button("SPC f t", "> Tree", ":NvimTreeToggle<CR>"),
  dashboard.button("SPC h f", "> Dotfiles", ":Dff<CR>"),
  dashboard.button("SPC h s", "> Dotfiles Search", ":Dfs<CR>"),
  dashboard.button("SPC z f", "> Zettelkastan", ":lua require('telekasten').find_notes()<CR>"),
  dashboard.button("q", "> Quit NVIM", ":qa<CR>"),
}

alpha.setup(dashboard.opts)
