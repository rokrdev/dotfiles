function f --description 'Fuzzy find file and open in vim'
    set files (echo (eval "$FZF_DEFAULT_COMMAND | fzf --multi --exit-0 --preview 'bat --style=plain --color=always --line-range :100 {}'"))
    if test -n $files
      nvim (echo $files | string split ' ')
    end
end
