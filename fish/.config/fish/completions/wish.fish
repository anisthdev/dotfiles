complete -c wish -n '__fish_use_subcommand' -a '(yq -r ".[] | select(has(\"ssh\")) |.name" "$SESSHIN_DIR/servers.yml" | fzf --preview "view_server {} | bat -l yml --color always -p")' -f
