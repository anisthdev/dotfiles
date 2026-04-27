function open -d "Open files and URLs detached from the terminal"
    if test (count $argv) -eq 0
        echo "Usage: open <file-or-url> [more paths or URLs]"
        return 1
    end

    command setsid -f xdg-open $argv >/dev/null 2>&1
end
