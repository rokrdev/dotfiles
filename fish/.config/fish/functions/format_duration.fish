function format_duration --description 'Format milliseconds into human-readable duration'

    set -l ms $argv[1]
    test -z "$ms"; and return
    test "$ms" -eq 0 2>/dev/null; and return

    set -l seconds (math -s0 "$ms / 1000")

    set -l parts

    # Month (30 days)
    if test $seconds -ge 2592000
        set -l months (math -s0 "$seconds / 2592000")
        set seconds (math -s0 "$seconds % 2592000")
        set -a parts {$months}mo
    end

    # Days
    if test $seconds -ge 86400
        set -l days (math -s0 "$seconds / 86400")
        set seconds (math -s0 "$seconds % 86400")
        set -a parts {$days}d
    end

    # Hours
    if test $seconds -ge 3600
        set -l hours (math -s0 "$seconds / 3600")
        set seconds (math -s0 "$seconds % 3600")
        set -a parts {$hours}h
    end

    # Minutes
    if test $seconds -ge 60
        set -l minutes (math -s0 "$seconds / 60")
        set seconds (math -s0 "$seconds % 60")
        set -a parts {$minutes}m
    end

    if test $seconds -gt 0 -o (count $parts) -eq 0
        if test (count $parts) -eq 0
            # Short duration - show ms or seconds
            if test $ms -lt 1000
                set -a parts {$ms}ms
            else
                set -l precise (math -s2 "$ms / 1000")
                set -a parts {$precise}s
            end
        else
            set -a parts {$seconds}s
        end
    end

    echo (string join ' ' $parts)

end
