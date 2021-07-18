set __fish_git_prompt_show_informative_status true
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
set -U fish_prompt_pwd_dir_length 0

function fish_prompt --description 'Write out the prompt'
    set -l git (fish_git_prompt)

    set -l prompt '❯ '

    set -l prompt_color green

    if test $status -ne 0
        set -l prompt_color red
    end

    set -l pwd (prompt_pwd)

    echo -n -s -e (set_color $fish_color_cwd) '\n' $pwd $git (set_color $prompt_color) '\n' $prompt
end
