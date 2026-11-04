function __gruvbox_colors --on-variable fish_terminal_color_theme
    set -l foreground ebdbb2
    set -l selection 504945
    set -l comment 8f3f71
    set -l red fb4934
    set -l orange fe8019
    set -l yellow fabd2f
    set -l green b8bb26
    set -l purple d3869b
    set -l cyan 8ec07c
    set -l blue 83a598

    # fish asks the terminal, and hears when it changes
    if test "$fish_terminal_color_theme" = light
        set foreground 3c3836
        set selection d5c4a1
        set red 9d0006
        set orange af3a03
        set yellow b57614
        set green 79740e
        set purple 8f3f71
        set cyan 427b58
        set blue 076678
    end

    # Syntax Highlighting Colors
    set -g fish_color_normal $foreground
    set -g fish_color_command $cyan
    set -g fish_color_keyword $blue
    set -g fish_color_quote $yellow
    set -g fish_color_redirection $foreground
    set -g fish_color_end $orange
    set -g fish_color_error $red
    set -g fish_color_param $purple
    set -g fish_color_comment $comment
    set -g fish_color_selection --background=$selection
    set -g fish_color_search_match --background=$selection
    set -g fish_color_operator $green
    set -g fish_color_escape $blue
    set -g fish_color_autosuggestion $comment

    # Completion Pager Colors
    set -g fish_pager_color_progress $comment
    set -g fish_pager_color_prefix $cyan
    set -g fish_pager_color_completion $foreground
    set -g fish_pager_color_description $comment
end
__gruvbox_colors
