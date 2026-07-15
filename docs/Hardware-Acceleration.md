# Hardware Acceleration

## Intel integrated graphics (VA-API)

This image ships the Intel VA-API drivers for hardware video decode/encode via the kernel DRM
stack:

| Package | Coverage |
|---|---|
| `intel-media-driver` (iHD) | Broadwell (2014) and newer |
| `libva-intel-driver` (i965) | Pre-Broadwell / legacy |
| `libva-utils` | `vainfo` diagnostic tool |

Both drivers are installed; the system selects the appropriate one based on the GPU.

## Checking VA-API status

```bash
ujust verify-hwaccel
# or directly:
vainfo
```

A working output looks like:

```
vainfo: VA-API version: 1.x.x
vainfo: Driver version: Intel iHD driver for Intel(R) Gen Graphics - x.x.x.x
VAProfileMPEG2Simple   VAEntrypointVLD
VAProfileH264Main      VAEntrypointVLD
VAProfileH264Main      VAEntrypointEncSlice
...
```

If `vainfo` returns `error: can't connect to X server` in a terminal, run it in a graphical
terminal or with `DISPLAY=:0 vainfo`.

## Codec support

Full codec support (including H.264, H.265, AV1, VP8/VP9) comes from **RPM Fusion**:

- `ffmpeg` — replaces the patent-limited version from Fedora's default repos
- `mesa-va-drivers-freeworld` — `mesa` with VA-API backend via the freeworld build

These are installed automatically — no manual action needed.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `vainfo` shows no profiles | Confirm kernel DRM driver is loaded: `lsmod \| grep i915` |
| Hardware decode not used in Firefox | Enable in `about:config`: `media.ffmpeg.vaapi.enabled = true` |
| Hardware decode not used in VLC | Check `Tools → Preferences → Input/Codecs → Hardware-accelerated decoding` |
| Build output shows `libva: va_getDriverName() failed` | May need a reboot after first install |
