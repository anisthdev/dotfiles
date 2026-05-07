alias v='nvim'
alias vi='nvim'
alias vim='nvim'

alias t='tmux'
alias ta='tmux attach || tmux new'
alias tl='tmux list-sessions'

alias gs='git status --short'
alias ga='git add'
alias gl='git log --oneline --graph --all'
alias gd='git diff'
alias gc='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gsw='git switch'

alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --group-directories-first'
alias lt='eza -T --icons'

alias cat='bat --style=auto'
alias less='bat --style=auto --paging=always'

alias c='clear'
alias h='history'
alias df='duf -only local,network,fuse -output filesystem,type,size,used,usage,mountpoint -hide-mp "/mnt/w*,/usr/*"'
alias du='dust -r'
alias mkdir='mkdir -p'

alias xleak='xleak -H -i'


alias sss='sudo systemctl status'
alias ssst='sudo systemctl start'
alias sssp='sudo systemctl stop'
alias sssr='sudo systemctl restart'
alias ssse='sudo systemctl enable'

alias uss='systemctl --user status'
alias usst='systemctl --user start'
alias ussp='systemctl --user stop'
alias ussr='systemctl --user restart'
alias usse='systemctl --user enable'

# transmission-remote
alias tr='transmission-remote'
alias tra='transmission-remote -a'

function tradd
    set -l input $argv[1]

    # If no argument, check clipboard for magnet link
    if test -z "$input"
        set input (wl-paste --type text 2>/dev/null | string match -r '^magnet:')
        if test -z "$input"
            echo "No torrent file, magnet link, or clipboard magnet found"
            return 1
        end
    end

    # Check if input is a magnet link
    if string match -qr '^magnet:' "$input"
        transmission-remote -a "$input"
    else
        # Assume it's a file path
        if test -f "$input"
            transmission-remote -a "$input"
        else
            echo "File not found: $input"
            return 1
        end
    end

    # Open tremc
    command tremc &
end
