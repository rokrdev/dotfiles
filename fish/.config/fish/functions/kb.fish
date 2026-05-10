function kb --description 'Show local kanban board'
    if not test -d .workflow/kanban
        echo "No .kanban/ directory in $(pwd)"
        return 1
    end

    for col in backlog doing done
        set count (count (ls -1 .workflow/kanban/$col/ 2>/dev/null))
        echo ""
        echo "── $col ($count) ──"
        for f in .workflow/kanban/$col/*.md
            test -e "$f" || continue
            set name (basename $f .md)
            # extract acceptance from frontmatter if present
            set acceptance (grep -m1 '^acceptance:' $f 2>/dev/null | string replace -r '^acceptance:\s*' '' | string trim --chars='"')
            if test -n "$acceptance"
                printf "  %-40s %s\n" $name $acceptance
            else
                echo "  $name"
            end
        end
    end
end
