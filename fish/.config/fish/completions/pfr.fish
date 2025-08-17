yq -r '.[] | "\(.name) \(.instance)"' $HOME/.config/work/servers.yml | while read -l name instance;
    complete -c pfr -n '__fish_use_subcommand' -a "$instance" -d "$name" -f
end
