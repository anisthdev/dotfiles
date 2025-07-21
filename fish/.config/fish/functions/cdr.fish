# quick cd to git repository root
function cdr -d "Jump to git repository root"
    set -l git_root (git rev-parse --show-toplevel 2> /dev/null)
    if test -n "$git_root"
        cd "$git_root"
    else
        echo "Not in a git repository"
    end
end
