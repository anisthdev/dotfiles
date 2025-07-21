# quickly find and edit a file in neovim
function f -d "Search and open files in Neovim"
    set -l file (rg --files --hidden --follow --glob "!.git/*" --glob "!**/node_modules/*"| fzf --tmux --preview "bat --color=always --style=numbers {}")
    if test -n "$file"
        nvim "$file"
    end
end
