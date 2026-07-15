#!/usr/bin/env bash
# Build script for the fedora-atomic-cosmic image.
# Runs inside the container build on top of quay.io/fedora-ostree-desktops/cosmic-atomic.
set -euxo pipefail

# On Fedora Atomic, /root and /home are symlinks into /var (roothome, home),
# which only get populated at first boot. Create the roothome target now so
# tools that write under $HOME (e.g. the Homebrew installer's cache dir)
# don't choke on a dangling symlink during the build.
mkdir -p /var/roothome

### RPM Fusion ##################################################################
# Free + nonfree repos for patent-encumbered codecs and hardware video accel
# drivers - the single most common manual step on any Fedora desktop.
dnf -y install \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

### Tailscale repo ##############################################################
curl -fsSL https://pkgs.tailscale.com/stable/fedora/tailscale.repo \
    -o /etc/yum.repos.d/tailscale.repo

### Layered packages ##########################################################
# - freeipa-client / krb5-workstation / oddjob-mkhomedir: FreeIPA enrollment
#   support (run `ipa-client-install --mkhomedir` on a deployed machine)
# - distrobox: mutable container distros for every user
# - git-core / zstd: needed to install and package Homebrew below
# - ffmpeg / mesa-*-freeworld: full RPM Fusion codec + hardware video accel
#   (replaces the patent-limited *-free builds shipped by default)
# - firewalld / avahi / nss-mdns / cups*: LAN discovery and network printing
# - tailscale: VPN mesh client (service enabled below; run `tailscale up`
#   after first boot to authenticate against your tailnet)
# - jetbrains-mono-fonts / fira-code-fonts: monospace coding fonts
dnf -y install --allowerasing \
    distrobox \
    freeipa-client \
    krb5-workstation \
    oddjob-mkhomedir \
    git-core \
    zstd \
    ffmpeg \
    mesa-va-drivers-freeworld \
    mesa-vdpau-drivers-freeworld \
    firewalld \
    avahi \
    nss-mdns \
    cups \
    cups-filters \
    cups-browsed \
    tailscale \
    jetbrains-mono-fonts \
    fira-code-fonts

### Homebrew ##################################################################
# Homebrew cannot live in the immutable /usr tree, so install it at build
# time, pack the prefix into a tarball shipped in /usr/share, and let
# brew-setup.service unpack it into /var/home/linuxbrew on first boot.
export HOMEBREW_NO_ANALYTICS=1
mkdir -p /var/home
# The Homebrew installer refuses to run as root unless it detects a container.
touch /.dockerenv
curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o /tmp/brew-install.sh
chmod +x /tmp/brew-install.sh
NONINTERACTIVE=1 /tmp/brew-install.sh
tar --zstd -cf /usr/share/homebrew.tar.zst -C /var/home linuxbrew
rm -rf /.dockerenv /tmp/brew-install.sh /var/home/linuxbrew

### Flatpak ####################################################################
# /etc is part of the ostree commit (and 3-way merged on every deployment), so
# a remote added here is present for every user on first login with no
# first-boot service needed.
flatpak remote-add --system --if-not-exists flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo

### Firewalld default zone #####################################################
# firewall-offline-cmd edits the on-disk zone config directly (no running
# daemon needed during the build). FedoraWorkstation is the zone Fedora
# Workstation itself uses: it permits mDNS/DNS-SD, SMB client, and SSH -
# the profile an actual desktop machine wants.
firewall-offline-cmd --set-default-zone=FedoraWorkstation

### Helper scripts and services ###############################################
chmod 0755 /usr/libexec/brew-setup.sh
systemctl enable \
    brew-setup.service \
    oddjobd.service \
    firewalld.service \
    avahi-daemon.service \
    cups.service \
    cups-browsed.service \
    tailscaled.service \
    rpm-ostreed-automatic.timer

### Cleanup ###################################################################
dnf clean all
rm -rf /var/cache/* /var/log/* /var/tmp/* 2>/dev/null || true
ostree container commit
