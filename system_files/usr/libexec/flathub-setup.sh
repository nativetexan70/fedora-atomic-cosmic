#!/usr/bin/env bash
# Make sure the system-wide Flathub remote exists so every user can install
# flatpaks from it. Cheap local check first; only touches the network when
# the remote is missing.
set -euo pipefail

if flatpak remotes --system --columns=name | grep -qx flathub; then
    exit 0
fi

flatpak remote-add --system --if-not-exists flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo
