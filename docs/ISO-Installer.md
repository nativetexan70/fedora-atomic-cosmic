# ISO Installer

Build a bootable ISO using [`bootc-image-builder`](https://github.com/osbuild/bootc-image-builder).
Run against the published GHCR image or a local build.

## Interactive installer ISO

```bash
mkdir -p output
sudo podman run --rm -it --privileged --pull=newer \
    --security-opt label=type:unconfined_t \
    -v ./output:/output \
    -v /var/lib/containers/storage:/var/lib/containers/storage \
    quay.io/centos-bootc/bootc-image-builder:latest \
    --type iso \
    --rootfs ext4 \
    ghcr.io/nativetexan70/fedora-atomic-cosmic:latest
```

The resulting `install.iso` lands in `./output/bootiso/`. `--rootfs ext4` is required — this
image does not set a default root filesystem.

## Build from a local image

```bash
# Build locally first
podman build -t fedora-atomic-cosmic .

# Then point bootc-image-builder at the local image
sudo podman run --rm -it --privileged --pull=newer \
    --security-opt label=type:unconfined_t \
    -v ./output:/output \
    -v /var/lib/containers/storage:/var/lib/containers/storage \
    quay.io/centos-bootc/bootc-image-builder:latest \
    --type iso \
    --rootfs ext4 \
    containers-storage:localhost/fedora-atomic-cosmic
```

## Unattended installer (kickstart)

Use `--type anaconda-iso` with a `config.toml` to bake partitioning, network config, and
other Anaconda settings into the ISO:

```bash
sudo podman run --rm -it --privileged --pull=newer \
    --security-opt label=type:unconfined_t \
    -v ./config.toml:/config.toml:ro \
    -v ./output:/output \
    -v /var/lib/containers/storage:/var/lib/containers/storage \
    quay.io/centos-bootc/bootc-image-builder:latest \
    --type anaconda-iso \
    --rootfs ext4 \
    ghcr.io/nativetexan70/fedora-atomic-cosmic:latest
```

`config.toml` example (wipes disk, sets up LVM, DHCP networking):

```toml
[customizations.installer.kickstart]
contents = """
text --non-interactive
zerombr
clearpart --all --initlabel --disklabel=gpt
autopart --noswap --type=lvm
network --bootproto=dhcp --device=link --activate --onboot=on
"""
```

`bootc-image-builder` appends the container install step to the kickstart automatically — do
not duplicate it.

## Requirements

- `podman` with root privileges (needed for disk partitioning)
- On SELinux-enforcing hosts: `osbuild-selinux` package installed
- Sufficient disk space in `/var/lib/containers/storage` for the image layers
