function git-cleanup --description 'Delete local branches already merged to main'
    git branch --merged main --no-color | grep -v '^\*' | grep -v '^ *main$' | while read -l branch
        git branch -d $branch
    end
end
