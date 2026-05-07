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
alias tradd='transmission-remote -a'
