# edit the main command to use the remaining path
function edit_first_command -d "Delete first command taking cursor to start of the line"
    set -l curr_command (string join " " (commandline -o | string split " " | tail -n +2))
    commandline " $curr_command"
    commandline --cursor 0
end
