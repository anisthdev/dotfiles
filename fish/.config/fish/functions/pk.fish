
function pk -d "Fuzzy-find and kill a running process"
    set -l pids (ps -ef | sed 1d | fzf -m --preview 'echo {}' --preview-window down:3:wrap | awk '{print $2}')
    if test -n "$pids"
        echo $pids | xargs kill -9
        echo "Killed PID(s): $pids"
    end
end
