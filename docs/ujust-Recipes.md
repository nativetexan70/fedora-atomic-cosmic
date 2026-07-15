# ujust Recipes

`ujust` is a wrapper around `just` provided by the `ublue-os-just` package. Run the
interactive picker or a recipe directly:

```bash
ujust --choose        # interactive menu
ujust <recipe>        # run directly
ujust <recipe> --help # some recipes print usage
```

## Available recipes

| Recipe | Description |
|---|---|
| `update` | Updates the base image, Flatpaks, and Homebrew packages in one shot |
| `rebase-helper` | Interactively rebase to a different tag of this image |
| `clean-system` | Removes old rpm-ostree deployments, unused podman images, and unused flatpak runtimes |
| `ipa-enroll` | Prompts for an IPA domain/server, runs `ipa-client-install --mkhomedir`, enables SSSD enumeration, and restarts affected services |
| `ipa-unenroll` | Removes this machine from its FreeIPA domain |
| `brew-status` | Shows whether Homebrew has been unpacked and who owns it |
| `brew-resync` | Re-runs the Homebrew first-boot unpack (e.g. after a home directory wipe) |
| `distrobox-create NAME IMAGE` | Creates and enters a distrobox container |
| `toggle-tailscale` | Enables/disables the Tailscale VPN mesh client |
| `toggle-login-manager` | Switches between GDM (default) and cosmic-greeter; warns before switching to cosmic-greeter due to the known FreeIPA/AD login bug |
| `verify-hwaccel` | Runs `vainfo` to check Intel VA-API hardware video acceleration |
| `toggle-terminal-bling` | Turns the default Starship/eza/bat/fastfetch terminal setup on or off |

## Recipe source

Recipes are defined in
`system_files/usr/share/ublue-os/just/60-custom.just` in the repository. The
`ublue-os-just` package generates a master justfile at build time that imports this file.

## Examples

```bash
# Enroll in a FreeIPA domain interactively
ujust ipa-enroll

# Switch from GDM to cosmic-greeter (after upstream bug fix)
ujust toggle-login-manager

# Full system update
ujust update

# Clean up old deployments and unused images/runtimes
ujust clean-system

# Create a Debian distrobox container
ujust distrobox-create mydebian docker.io/library/debian:latest

# Check VA-API hardware acceleration
ujust verify-hwaccel
```
