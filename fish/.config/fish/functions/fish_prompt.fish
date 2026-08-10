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

    set -l prompt ' '

    set -l prompt_color red

    if test $_display_status -eq 0
        set prompt_color green
        set error_gap = '\n'
    end

    set -l pwd (prompt_pwd)

    # Helix mode indicator: only shown when helix key bindings are active.
    set -l mode_indicator ''
    if test "$fish_key_bindings" = fish_helix_key_bindings
        switch $fish_bind_mode
            case default
                set mode_indicator (set_color brblue)''(set_color normal)
            case insert
                set mode_indicator (set_color brcyan)''(set_color normal)
            case replace replace_one
                set mode_indicator (set_color bryellow)''(set_color normal)
            case visual
                set mode_indicator (set_color brmagenta)''(set_color normal)
        end
    end

    set -l duration (format_duration $CMD_DURATION)
    if test -n "$duration"
        echo -s -e (set_color brblack) "=== $duration ===" (set_color normal)
    end

    echo -n -s -e $mode_indicator ' ' (set_color $fish_color_cwd) $pwd $git ' ' (set_color white) (date +%H:%M:%S) '\n' (set_color $prompt_color) $prompt
end
