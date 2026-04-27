# quickly find and open a non-hidden file
function f -d "Search and open non-hidden files"
    set -l file (rg --files --follow --glob "!.git/*" --glob "!**/node_modules/*" | fzf --ansi --tmux --preview "$HOME/.local/bin/preview {}")
    if test -n "$file"
        open "$file"
    end
end
