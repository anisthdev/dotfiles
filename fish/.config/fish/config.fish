set -x PATH $PATH:$HOME/.local/bin
set -x TMUX_CONF $HOME/.config/tmux/.tmux.conf
set -x TNS_ADMIN /opt/instantclient/network/admin

# initiate starship
starship init fish | source

# initiate fzf
fzf --fish | source
set -gx FZF_DEFAULT_COMMAND 'rg --files --hidden --follow --glob "!.git/*"'
set -gx FZF_CTRL_T_COMMAND 'fd --type f --hidden --follow --exclude .git'
set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --follow --exclude .git'
set -gx FZF_DEFAULT_OPTS '--layout=reverse --tmux --border --preview "bat --color=always --style=numbers {}"'

# intiate atuin
atuin init fish --disable-up-arrow | source

# color setting for fish prompt
set -g fish_color_command green
set -g fish_color_param cyan
set -g fish_color_error red
set -g fish_color_comment brblack
set -g fish_color_quote yellow

# neovim as editor
set -gx EDITOR nvim
set -gx VISUAL nvim

# aliases
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
alias df='df -h'
alias du='du -h'
alias mkdir='mkdir -p'

# quick cd to git repository root
function cdr -d "Jump to git repository root"
    set -l git_root (git rev-parse --show-toplevel 2> /dev/null)
    if test -n "$git_root"
        cd "$git_root"
    else
        echo "Not in a git repository"
    end
end

# quickly find and edit a file in neovim
function f -d "Search and open files in Neovim"
    set -l file (rg --files --hidden --follow --glob "!.git/*" --glob "!**/node_modules/*"| fzf --tmux --preview "bat --color=always --style=numbers {}")
    if test -n "$file"
        nvim "$file"
    end
end

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

function gf -d "Fuzzy-find git log and return commit hash"
    set -l commit (git log --color=always --pretty=format:'%C(yellow)%h %C(reset)%s %C(bold blue)<%an>%C(reset) %C(green)(%cr)%C(reset)' |
        fzf --ansi --no-sort --reverse --tiebreak=index --preview 'git show --color=always {1}' --bind 'ctrl-y:execute-silent(echo -n {1} | tmux load-buffer -)+abort')

    if test -n "$commit"
        echo "$commit" | awk '{print $1}'
    end
end

function pk -d "Fuzzy-find and kill a running process"
    set -l pids (ps -ef | sed 1d | fzf -m --preview 'echo {}' --preview-window down:3:wrap | awk '{print $2}')

    if test -n "$pids"
        echo $pids | xargs kill -9
        echo "Killed PID(s): $pids"
    end
end

# disable fish greeting
set -g fish_greeting
