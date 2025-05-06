if status is-interactive
    # Commands to run in interactive sessions can go here
    starship init fish | source
    alias ls=eza
    alias ll='eza -l'
    alias gs='git status'
	alias vim=nvim
    function f
        set dir (count $argv) > /dev/null; and set dir $argv[1]; or set dir .

        if test -n "$TMUX"
            set selected (fd --type f --hidden --exclude .git . $dir | fzf-tmux -p --reverse)
        else
            set selected (fd --type f --hidden --exclude .git . $dir | fzf --height=40% --border --layout=reverse)
        end

        if test -n "$selected"
            nvim $selected
        end
    end
    # vim ~/.config/fish/functions/sdk.fish:
    function sdk
        bash -c "source '$HOME/.sdkman/bin/sdkman-init.sh'; sdk $argv[1..]"
    end

    fish_add_path (find "$HOME/.sdkman/candidates/java/current/bin" -maxdepth 0)
end
