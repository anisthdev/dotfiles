function tradd
    set -l input $argv[1]

    # If no argument, check clipboard for magnet link
    if test -z "$input"
        set input (wl-paste --type text 2>/dev/null)
        if not string match -qr '^magnet:' -- "$input"
            set input ""
        end
    end

    if test -z "$input"
        echo "No torrent file, magnet link, or clipboard magnet found"
        return 1
    end

    # Check if input is a magnet link
    if string match -qr '^magnet:' -- "$input"
        transmission-remote -a "$input" > /dev/null
    else
        # Assume it's a file path
        if test -f "$input"
            transmission-remote -a "$input" > /dev/null
        else
            echo "File not found: $input"
            return 1
        end
    end

    # Open tremc
    command tremc
end
