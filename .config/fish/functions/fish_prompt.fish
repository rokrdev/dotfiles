set __fish_git_prompt_show_informative_status
set __fish_git_prompt_showcolorhints 'yes'
set __fish_git_prompt_showupstream 'informative'
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_char_cleanstate '✔'
set __fish_git_prompt_char_dirtystate '◆'
set __fish_git_prompt_char_upstream_ahead '↑'
set __fish_git_prompt_char_upstream_behind '↓'
set __fish_git_prompt_char_upstream_diverged '<>'
set __fish_git_prompt_color_upstream cyan
set fish_color_cwd blue
set __fish_git_prompt_color_branch magenta

function fish_prompt --description 'Write out the prompt'
    set -l prompt ' ~>> '

    set -l prompt_color magenta
    if test $status -ne 0
        set prompt_color red
    end

    set -l path (prompt_pwd)
    if test $path = '~'
        set pwd ''
        set prompt '~>> '
    else
        set pwd $path
    end

    set vcs (fish_vcs_prompt)
    echo -n -s (set_color $fish_color_cwd) $pwd $vcs (set_color $prompt_color) $prompt
end
