function ytmd -d "Download YouTube audio by URL or ID"
    if test -z "$argv[1]"
        echo "Usage: ytd <youtube_url_or_id>"
        return 1
    end

    set -l video_input $argv[1]

    # If the input doesn't contain 'http', assume it's a video ID
    if not string match -q -- "http*" "$video_input"
        set video_input "https://www.youtube.com/watch?v=$video_input"
    end

    echo "Downloading audio from $video_input"
    yt-dlp -x --audio-format mp3 -o "$HOME/Music/%(title)s.%(ext)s" --prefer-ffmpeg --embed-thumbnail -f 'bestaudio/best' "$video_input"
end
