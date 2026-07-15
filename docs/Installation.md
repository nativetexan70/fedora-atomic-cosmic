# Installation

## Prerequisites

- An existing Fedora Atomic or bootc system (Fedora Silverblue, Kinoite, another bootc image,
  or this image itself)
- Network access to GHCR (`ghcr.io`)

## Rebase from an existing Fedora Atomic system

With `bootc` (Fedora 40+):

```bash
sudo bootc switch ghcr.io/nativetexan70/fedora-atomic-cosmic:latest
sudo reboot
```

With `rpm-ostree` (older systems):

```bash
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/nativetexan70/fedora-atomic-cosmic:latest
sudo reboot
```

## Install from scratch (bare metal or VM)

Use the bootable ISO — see [ISO Installer](ISO-Installer.md).

## Available tags

| Tag | Meaning |
|---|---|
| `latest` | Current stable build |
| `44` | Fedora 44 pinned build |
| `YYYYMMDD` | Date-stamped snapshot |

The image is rebuilt weekly and on every push to `main`, so `latest` stays current with
upstream base-image and package updates automatically.

## After rebasing

1. Reboot into the new deployment.
2. On first boot, `brew-setup.service` unpacks Homebrew and `flathub-setup.service` adds the
   Flathub remote and installs the default app set. Both run in the background — allow a few
   minutes for Flatpak installs to complete on a slow connection.
3. If enrolling in a FreeIPA domain, see [FreeIPA Integration](FreeIPA-Integration.md).
4. To authenticate with Tailscale, run `tailscale up` (see [Tailscale](Tailscale.md)).

## Verifying the install

```bash
# Confirm the active image
bootc status

# Check Homebrew unpacked correctly
ujust brew-status

# Verify Intel hardware video acceleration
ujust verify-hwaccel

# List installed Flatpak apps
flatpak list --app
```
