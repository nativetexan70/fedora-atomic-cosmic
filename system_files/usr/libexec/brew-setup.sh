#!/usr/bin/env bash
# Unpack the Homebrew prefix shipped in the image into /var/home/linuxbrew.
# Runs once via brew-setup.service; a no-op if brew is already present.
set -euo pipefail

BREW_BIN=/var/home/linuxbrew/.linuxbrew/bin/brew
TARBALL=/usr/share/homebrew.tar.zst

if [ -x "${BREW_BIN}" ]; then
    exit 0
fi

if [ ! -f "${TARBALL}" ]; then
    echo "brew-setup: ${TARBALL} not found" >&2
    exit 1
fi

mkdir -p /var/home
tar --zstd -xf "${TARBALL}" -C /var/home

# Homebrew requires a single owning user for its prefix; hand it to the
# primary (first-created, UID 1000) user. Every other user still gets the
# binaries on PATH via /etc/profile.d/brew.sh.
chown -R 1000:1000 /var/home/linuxbrew

if command -v restorecon >/dev/null 2>&1; then
    restorecon -R /var/home/linuxbrew || true
fi
