function grm --description 'From a branch, git pull main/master and rebase'
    git fetch origin
    git rebase origin/(git branch --format='%(refname:short)' --list main master | head -n 1) --autostash
end
