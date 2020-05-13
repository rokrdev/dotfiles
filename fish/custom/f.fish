function f --description 'Fuzzy find file and open in vim'
    set files (echo (eval "$FZF_DEFAULT_COMMAND | fzf --multi --exit-0"))
    if test -n $files
      v (echo $files | string split ' ')
    end
end

