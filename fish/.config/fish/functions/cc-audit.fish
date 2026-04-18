function cc-audit --description "Tail the auto-approve decision log"
    set log ~/.claude/logs/auto-approve.jsonl
    if not test -f $log
        echo "No auto-approve log found at $log"
        echo "Run cc-auto to start logging."
        return 1
    end
    tail -f $log | jq --unbuffered '.'
end
