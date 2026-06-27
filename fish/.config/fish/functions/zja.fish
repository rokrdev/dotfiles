function zja -d "Fuzzy find and attach to a Zellij session"
    # Get the list of active Zellij session names
    set -l sessions (zellij list-sessions -n)

    if test -z "$sessions"
        # No sessions exist; create a new one
        zellij
    else
        set -l target (printf '%s\n' $sessions | fzf --exit-0)

        # If a session was selected, extract name and attach
        if test -n "$target"
            set -l session_name (string split ' ' -- $target)[1]
            zellij attach $session_name
        end
    end
end
