function fzf_history_search
    history merge
    history -z | fzf --read0 --print0 --tiebreak=index | read -lz result
    and commandline -- $result
    commandline -f repaint
end
