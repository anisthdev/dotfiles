# complete -c wish -n '__fish_use_subcommand' -a '(sesshin list --ssh | fzf --preview "sesshin describe {} | bat -l yml --color always -p")' -f
yq -r '.[] | "\(.name) \(.instance)"' "$SESSHIN_DIR/servers.yml" | while read -l name instance;
    complete -c wish -n '__fish_use_subcommand' -a "$instance" -d "$name" -f
end

