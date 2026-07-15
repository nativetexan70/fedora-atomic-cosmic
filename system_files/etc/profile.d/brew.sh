# Put Homebrew on PATH (plus MANPATH/INFOPATH) for every user.
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    case ":${PATH}:" in
        *:/home/linuxbrew/.linuxbrew/bin:*) ;;
        *) eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" ;;
    esac
fi
