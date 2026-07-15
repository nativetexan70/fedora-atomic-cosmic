# Flatpak and Flathub

## Default app set

The following apps are installed from Flathub on first boot:

| App | Flatpak ID |
|---|---|
| Firefox | `org.mozilla.firefox` |
| Thunderbird | `org.mozilla.Thunderbird` |
| Flatseal (Flatpak permission manager) | `com.github.tchx84.Flatseal` |
| Warehouse (Flatpak manager UI) | `io.github.flattool.Warehouse` |
| Déjà Dup (backup) | `org.gnome.DejaDup` |
| Mission Center (system monitor) | `io.missioncenter.MissionCenter` |
| GNOME Connections (remote desktop) | `org.gnome.Connections` |

## Why first boot, not build time

Flatpak's system installation lives under `/var/lib/flatpak/`, which is excluded from the
ostree image commit (treated like a Docker `VOLUME`). Any `flatpak remote-add` or
`flatpak install` run during the image build is silently discarded and never reaches the
deployed system.

`flathub-setup.service` runs `flatpak remote-add` and `flatpak install` at first boot, when
`/var` is real. The service is idempotent — already-installed apps are skipped — so it's safe
to run on every boot.

## Installing additional apps

```bash
# Search Flathub
flatpak search <name>

# Install a Flatpak
flatpak install flathub <app-id>

# Update all installed Flatpaks (also part of `ujust update`)
flatpak update -y
```

## Managing apps

Use **Warehouse** (pre-installed) for a graphical interface to manage installed Flatpaks,
clear app data, and inspect permissions.

Use **Flatseal** to review and adjust per-app Flatpak permissions.

## Cleanup

```bash
# Remove unused Flatpak runtimes (also part of `ujust clean-system`)
flatpak uninstall --unused -y
```
