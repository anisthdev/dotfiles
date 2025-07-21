# tmux session based on workspace directory
function tms -d "Tmux sessionizer"
    set -l dir
    if count $argv > 0
        set dir $argv[1]
    else
        set dir (fd --type d --hidden --follow --exclude .git | fzf --prompt="Select directory: ")
    end
    if test -n "$dir" && test -d "$dir"
        set -l session_name (basename (realpath "$dir") | tr . _)
        if not tmux has-session -t "$session_name" 2> /dev/null
            tmux new-session -d -s "$session_name" -c "$dir"
        end
        if test -n "$TMUX"
            tmux switch-client -t "$session_name"
        else
            tmux attach-session -t "$session_name"
        end
    end
end
