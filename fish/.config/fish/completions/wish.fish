complete -c wish -n '__fish_use_subcommand' -a '(sesshin list --ssh | fzf --preview "sesshin describe {} | bat -l yml --color always -p")' -f
