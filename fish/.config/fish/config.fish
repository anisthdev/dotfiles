set -x PATH $PATH:$HOME/.local/bin
set -x TMUX_CONF $HOME/.config/tmux/.tmux.conf
set -x TNS_ADMIN /opt/instantclient/network/admin
set -x SESSHIN_DIR $HOME/.config/sesshin

# initiate tools
starship init fish | source
atuin init fish --disable-up-arrow | source
fzf --fish | source

# initiate fzf
set -gx FZF_DEFAULT_COMMAND 'rg --files --hidden --follow --glob "!.git/*"'
set -gx FZF_CTRL_T_COMMAND 'fd --type f --hidden --follow --exclude .git'
set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --follow --exclude .git'
set -gx FZF_DEFAULT_OPTS '--layout=reverse --tmux --border --preview "bat --color=always --style=numbers {}"'

# neovim as editor
set -gx EDITOR nvim
set -gx VISUAL nvim

# map keybindings
bind \cg edit_first_command

# disable fish greeting
set -g fish_greeting
