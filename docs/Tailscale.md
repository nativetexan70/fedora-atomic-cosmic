# Tailscale

Tailscale is pre-installed and `tailscaled` is enabled at image build time. The daemon starts
automatically on boot, but you must authenticate to your tailnet before any VPN connectivity
is available.

## First-time setup

After deploying or rebasing:

```bash
tailscale up
```

Follow the authentication URL printed to the terminal to log in to your Tailscale account.

## Enabling / disabling

```bash
ujust toggle-tailscale
```

This enables or disables `tailscaled` depending on the current state. When re-enabling, run
`tailscale up` again if the session has expired.

Or manually:

```bash
# Disable
sudo systemctl disable --now tailscaled

# Enable
sudo systemctl enable --now tailscaled
tailscale up
```

## Status

```bash
tailscale status
tailscale ip
```

## Updates

Tailscale is installed from [Tailscale's own Fedora repo](https://pkgs.tailscale.com/stable/fedora/).
Package updates arrive via the normal image rebuild cycle (weekly or on push to `main`).
