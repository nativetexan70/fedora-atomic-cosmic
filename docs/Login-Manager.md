# Login Manager

## Default: GDM

This image uses **GDM** as the login manager instead of the COSMIC default (`cosmic-greeter`).
GDM correctly authenticates any typed username — including FreeIPA/AD domain accounts — by
forwarding the username to PAM/SSSD.

To switch between GDM and `cosmic-greeter`:

```bash
ujust toggle-login-manager
```

The recipe detects which display manager is currently active and switches to the other.
Switching to `cosmic-greeter` shows a warning about the known upstream bug (see below) and
asks for confirmation before proceeding. Reboot after switching for the change to take effect.

## Why not cosmic-greeter?

`cosmic-greeter` has a confirmed upstream bug
([pop-os/cosmic-greeter#376](https://github.com/pop-os/cosmic-greeter/issues/376)) where a
manually typed domain username (FreeIPA or Active Directory) never reaches PAM/SSSD at all.
Instead it silently opens a session for a different local account with no error shown.

Verified during a live failed IPA login attempt via:

```bash
journalctl -u cosmic-greeter -u cosmic-greeter-daemon -f
```

No `pam_sss` invocation appeared anywhere in the log, confirming the typed username was never
submitted to PAM. SSSD configuration (enumeration, HBAC), IPA server config, and UID ranges
were all checked and ruled out — this is a client-side defect in `cosmic-greeter` itself.

GDM does not have this problem: it correctly passes the typed username to PAM/SSSD and
`pam_sss` authenticates against the IPA realm normally.

## Switching back to cosmic-greeter

Once [pop-os/cosmic-greeter#376](https://github.com/pop-os/cosmic-greeter/issues/376) is
fixed upstream and the fix has shipped in a Fedora package update:

```bash
ujust toggle-login-manager
# Confirm the warning prompt
sudo reboot
```

Do not switch back without first confirming the fix is in the installed `cosmic-greeter`
package version (`rpm -q cosmic-greeter`).

## Lock screen

The lock screen is **not** handled by GDM. It is provided by `cosmic-comp` (the COSMIC
compositor) via the `ext-session-lock-v1` Wayland protocol. When you lock your session
(Super+L or idle timeout), control goes to `cosmic-comp`'s built-in lock screen — GDM is not
involved. This means:

- **Login screen** (boot / log out): GDM — handles typed IPA usernames correctly
- **Lock screen** (Super+L / idle): `cosmic-comp` — uses the standard PAM stack and works
  correctly for IPA users

The `cosmic-greeter` upstream bug specifically affects the initial login manager, not the lock
screen. FreeIPA password authentication at the lock screen goes through `pam_sss` normally.
