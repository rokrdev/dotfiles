set __fish_git_prompt_show_informative_status true
set __fish_git_prompt_showcolorhints yes
set __fish_git_prompt_showupstream informative
set __fish_git_prompt_showdirtystate yes
set __fish_git_prompt_char_cleanstate '✔'
set __fish_git_prompt_char_dirtystate '◆'
set __fish_git_prompt_char_upstream_ahead '↑'
set __fish_git_prompt_char_upstream_behind '↓'
set __fish_git_prompt_char_upstream_diverged '<>'
set __fish_git_prompt_color_upstream cyan
set __fish_git_prompt_color_branch magenta
set -U fish_prompt_pwd_dir_length 0

# set -U fish_color_cwd blue
# set -U fish_color_cwd_root red

function fish_prompt --description 'Write out the prompt'
    set -l _display_status $status

    set -l git (fish_git_prompt)

    # set -l prompt '⟫ '
    # set -l prompt '󰘩 '
    set -l prompt '󰈸 '

    set -l prompt_color red

    if test $_display_status -eq 0
        set prompt_color green
        set error_gap = '\n'
    end

    set -l pwd (prompt_pwd)

    # set -l hermit ''
    # if test -n "$HERMIT_ENV"
    #     set hermit '🐚 '
    # end

    set -l duration (format_duration $CMD_DURATION)
    if test -n "$duration"
        echo -s -e (set_color brblack) "=== $duration ===" (set_color normal)
    end

    echo -n -s -e (set_color $fish_color_cwd) $pwd $git $hermit(set_color $purple) ' ' (date +%H:%M:%S) '\n' (set_color $prompt_color) $prompt
end
