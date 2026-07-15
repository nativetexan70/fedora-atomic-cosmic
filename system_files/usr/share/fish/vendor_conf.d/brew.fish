# Put Homebrew on PATH for fish users.
if test -x /home/linuxbrew/.linuxbrew/bin/brew; and not contains /home/linuxbrew/.linuxbrew/bin $PATH
    /home/linuxbrew/.linuxbrew/bin/brew shellenv | source
end
