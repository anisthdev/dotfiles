# start hyprland
if status is-interactive; and test "$XDG_VTNR" = 1; and test -z "$WAYLAND_DISPLAY"; and uwsm check may-start
  exec uwsm start -e -D Hyprland hyprland.desktop
end

fish_add_path $HOME/.local/bin
fish_add_path $HOME/.sdks/flutter/bin
set -x TMUX_CONF $HOME/.config/tmux/.tmux.conf
set -x TNS_ADMIN /opt/instantclient/network/admin
set -x SESSHIN_DIR $HOME/.config/sesshin
set -x SYSTEM_TEME gruvbox
set -x BAT_THEME gruvbox-dark

# initiate tools
starship init fish | source
fzf --fish | source
atuin init fish --disable-up-arrow | source

# configure fzf
set -gx FZF_DEFAULT_COMMAND 'rg --files --follow --glob "!.git/*" --glob "!node_modules/*"'
set -gx FZF_CTRL_T_COMMAND 'fd --type f --follow --exclude .git --exclude node_modules'
set -gx FZF_ALT_C_COMMAND 'fd --type d --follow --exclude .git --exclude node_modules'
set -gx FZF_DEFAULT_OPTS "--layout=reverse --tmux --preview '$HOME/.local/bin/preview {}'"

# neovim as editor
set -gx EDITOR nvim
set -gx VISUAL nvim

# map keybindings
bind \cg efc

# opencode
fish_add_path /home/asif/.opencode/bin
