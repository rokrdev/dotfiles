function setscheme
    if test -z "$argv"
        return 1
    end

    if test -f $HOME/.config/fish/colors/$argv[1].fish
        source $HOME/.config/fish/colors/$argv[1].fish
    end
end
