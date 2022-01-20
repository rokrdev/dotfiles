function ff --description 'Fuzzy find text and open in vim'
    set -l rgCommand "rg -i -l --hidden"
    set file (echo (eval "FZF_DEFAULT_COMMAND='rg --files' fzf \
      -m \
      -e \
      --ansi \
      --disabled \
      --bind 'change:reload:$rgCommand {q} || true' \
      --preview 'rg -i --pretty --context 2 {q} {}' | cut -d':' -f1,2"))
    if test -n $file
      nvim (echo $file)
    end
end
