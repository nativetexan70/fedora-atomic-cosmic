# Building the Image

## Local build

```bash
podman build -t fedora-atomic-cosmic .
```

## Syntax checks (no full build needed)

```bash
# Check the build script for syntax errors
bash -n build_files/build.sh

# List ujust recipes (requires `just` installed locally)
just --justfile system_files/usr/share/ublue-os/just/60-custom.just --list
```

## How the image is structured

Three pieces compose the image, wired together by `Containerfile`:

1. **`Containerfile`** — pulls `quay.io/fedora-ostree-desktops/cosmic-atomic:44`, copies
   `system_files/` onto `/`, then runs `build_files/build.sh`.

2. **`build_files/build.sh`** — the only place packages are installed and repos are enabled.
   Runs as a single `RUN` step with `set -euxo pipefail`. Order matters — repos must be
   enabled before installing packages from them.

3. **`system_files/`** — a literal overlay onto `/`. Whatever file exists here at a given
   path becomes that file in the image (systemd units, `/etc` defaults, profile scripts,
   helper scripts).

## CI

GitHub Actions (`.github/workflows/build.yml`) builds on:
- Every push to `main` (non-`.md` files)
- Every PR (build only, no push)
- Weekly on Monday at 05:20 UTC (to pick up upstream base-image / package updates)
- Manual workflow dispatch

On non-PR events, the built image is pushed to GHCR with tags `latest`, `44`, and `YYYYMMDD`.

## Versioning

The base image is pinned to `FEDORA_VERSION=44` in both `Containerfile` and
`.github/workflows/build.yml`. To update to a new Fedora release:

1. Bump `FEDORA_VERSION` in `Containerfile` (`ARG FEDORA_VERSION=45`)
2. Bump `FEDORA_VERSION` in `.github/workflows/build.yml` (`FEDORA_VERSION: "45"`)
3. Confirm both `tags:` lines in the workflow include the new version number

`build.sh` reads the live Fedora release via `rpm -E %fedora` for RPM Fusion URLs — it
adapts automatically and doesn't need changing.

Note: `quay.io/fedora-ostree-desktops/cosmic-atomic` does **not** publish a `:latest` tag —
only versioned tags (`:44`, `:43`, etc.).

## Common build failures

| Error | Cause | Fix |
|---|---|---|
| `No match for argument: <package>` | Package not in enabled repos | Check whether it needs RPM Fusion, a COPR, or an exact name change |
| `mkdir: cannot create directory '/root': File exists` | Tool writing to `$HOME` during build | Add `mkdir -p /var/roothome` before the offending command |
| RPM Fusion mirror timeout | Transient mirror failure | CI retries via `curl --retry 5 --max-time 40` |
| `manifest unknown` | Wrong base image tag | `cosmic-atomic` has no `:latest`; use a version number |
