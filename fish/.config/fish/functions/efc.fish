# edit the main command to use the remaining path
function efc -d "Edit first command taking cursor to start of the line"
    set -l tokens (commandline -xp)
    set -l new_cmd (string join -- " " $tokens[2..])
    commandline --replace -- " $new_cmd"
    commandline --cursor 0
end

