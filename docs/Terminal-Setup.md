# Terminal Setup

## What's included

| Tool | Role |
|---|---|
| [Starship](https://starship.rs) | Cross-shell prompt with git status, language version, etc. |
| [eza](https://github.com/eza-community/eza) | Modern `ls` replacement with colour and icons |
| [bat](https://github.com/sharkdp/bat) | `cat` replacement with syntax highlighting |
| [fastfetch](https://github.com/fastfetch-cli/fastfetch) | System info banner on shell open |

These are wired up for bash, zsh, and fish via `/etc/profile.d/terminal.sh` and
`/usr/share/fish/vendor_conf.d/terminal.fish`. The config is interactive-shell only — scripts
and non-interactive sessions are not affected.

## Shell aliases

| Command | Alias for |
|---|---|
| `ls` | `eza` |
| `ll` | `eza -lh` |
| `la` | `eza -lha` |
| `cat` | `bat` |

## Toggling

To turn the terminal setup on or off without removing packages:

```bash
ujust toggle-terminal-bling
```

This renames the profile.d and fish config files to `.disabled` (off) or back (on). Open a
new shell after toggling to see the change.

## Customising Starship

Starship reads `~/.config/starship.toml` for per-user configuration. The system-wide default
is the out-of-the-box Starship preset. To customise:

```bash
starship preset <preset-name> -o ~/.config/starship.toml
# or edit directly:
nano ~/.config/starship.toml
```

See [starship.rs/config](https://starship.rs/config/) for the full reference.

## Package sources

- `starship` is installed from the [`atim/starship`](https://copr.fedorainfracloud.org/coprs/atim/starship/)
  COPR — it was removed from Fedora's official repos at F37.
- `eza` and `bat` are from Fedora's official repos.
- `fastfetch` is from Fedora's official repos.
