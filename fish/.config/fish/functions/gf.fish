
function gf -d "Fuzzy-find git log and return commit hash"
    set -l commit (git log --color=always --pretty=format:'%C(yellow)%h %C(reset)%s %C(bold blue)<%an>%C(reset) %C(green)(%cr)%C(reset)' |
        fzf --ansi --no-sort --reverse --tiebreak=index --preview 'git show --color=always {1}' --bind 'ctrl-y:execute-silent(echo -n {1} | tmux load-buffer -)+abort')
    if test -n "$commit"
        echo "$commit" | awk '{print $1}'
    end
end
