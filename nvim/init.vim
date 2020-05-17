
source ~/.config/nvim/plug.vim
source ~/.config/nvim/functions.vim
source ~/.config/nvim/config.vim

for rcfile in split(globpath("~/.config/nvim/plugins", "*.vim"), '\n')
  execute('source '.rcfile)
endfor
