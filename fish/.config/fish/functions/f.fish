function f --description 'Fuzzy find file and open in vim'
    set file (echo (eval "$FZF_DEFAULT_COMMAND | fzf --exit-0 --preview 'bat --style=plain --color=always --line-range :100 {}'"))
    if test -n $file
        $EDITOR (echo $file)
    end
end
