# quickly find and open a file, including hidden files
function fh -d "Search and open files including hidden files"
    set -l file (rg --files --hidden --follow --glob "!.git/*" --glob "!**/node_modules/*" | fzf --ansi --tmux)
    if test -n "$file"
        open "$file"
    end
end
