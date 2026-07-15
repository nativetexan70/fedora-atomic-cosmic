# FreeIPA Integration

This image ships `freeipa-client`, `krb5-workstation`, and `oddjob-mkhomedir` — all the
packages needed to join a FreeIPA realm are pre-installed. `oddjobd` is enabled so home
directories are created automatically on first login for IPA users.

## Enrolling

The easiest path is the interactive `ujust` recipe:

```bash
ujust ipa-enroll
```

This prompts for your IPA domain and (optionally) a specific server, runs
`ipa-client-install --mkhomedir`, enables SSSD enumeration in `sssd.conf` (useful if you plan
to use `cosmic-greeter` — not required with GDM), then restarts the affected services.

To enroll manually:

```bash
sudo ipa-client-install --mkhomedir --domain YOUR.DOMAIN
sudo systemctl restart sssd oddjobd certmonger
```

Restarting services avoids a reboot in most cases: `ipa-client-install` rewrites
`sssd.conf`/`krb5.conf`/PAM+NSS config, but already-running services cache the old config in
memory. A reboot may still be needed occasionally.

## IPA accounts at the login screen

With GDM (this image's default login manager), you don't need IPA accounts to appear in a
list — GDM accepts any typed username and forwards it to PAM/SSSD. Just type the IPA username
at the login screen.

If you switch to `cosmic-greeter` via `ujust toggle-login-manager`, IPA accounts won't appear
in the greeter by default because SSSD disables enumeration for IPA/AD domains. Enable it:

```bash
sudo sed -i "/^\[domain\/YOUR.DOMAIN\]/a enumerate = True" /etc/sssd/sssd.conf
sudo systemctl restart sssd
```

`ujust ipa-enroll` sets this automatically. For large corporate directories, skip enumeration
and use GDM instead.

## UID range note

FreeIPA sometimes auto-assigns UID ranges in the billions to avoid cross-domain collisions. If
accounts are enrolled but won't show in a greeter (not GDM), check:

```bash
ipa idrange-show
```

Some greeters filter user lists to a "human user" UID range that may not include those values.

## Unenrolling

```bash
ujust ipa-unenroll
```

or manually:

```bash
sudo ipa-client-install --uninstall
```

## Troubleshooting

| Symptom | Check |
|---|---|
| Login fails with "Authentication failure" | `systemctl status sssd` — restart if stopped; reboot if still failing |
| Home directory not created on first login | `systemctl status oddjobd` — must be running |
| Kerberos tickets not working | `klist` — check ticket expiry; `kinit` to renew |
| DNS resolution fails for IPA server | Check `/etc/resolv.conf` — `ipa-client-install` sets this; confirm nameserver is reachable |
| Lock screen authentication fails | Same PAM stack as login; if `sssd` is running and IPA server is reachable, try `sudo systemctl restart sssd` |
